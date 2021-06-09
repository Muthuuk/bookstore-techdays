//
// This script expects to be running in the context of a Pull Request trigger so that it can communicate with the
//  user via the Pull Request, Comments and Labels.
//
module.exports = class DeploymentLabel {

  constructor(context, core, github) {
    this.context = context;
    this.core = core;
    this.github = github;
  }

  async acknowledgeDeployLabel() {
    const context = this.context
      , github = this.github
      , core = this.core
      ;

    const label = context.payload.label.name.toLowerCase();

    core.startGroup('context');
    core.info(JSON.stringify(context, null, 2));
    core.endGroup();

    const containers = await this.getContainerStatuses();
    core.startGroup('container statuses');
    core.info(JSON.stringify(containers));
    core.endGroup();

    if (!containers || containers.length === 0) {
      await this.postNoContainerStatus();
      core.setFailed('No containers found, cannot deploy anything...');
    } else {
      // Extract the containers, post a message to the user acknowledging the request and provide outputs for action steps
      await this.postDeploymentComment(label, containers);
      // Expose the container details
      containers.forEach(container => {
        core.setOutput(`${container.type}_container_image`, container.image);
        core.setOutput(`${container.type}_container_version`, container.version);
      });
    }

    // Remove the label
    await github.issues.removeLabel({
      ...context.repo,
      issue_number: context.issue.number,
      name: context.payload.label.name
    });
  }

  async getContainerStatuses() {
    const context = this.context
      , github = this.github
      , self = this;
    ;

    return github.repos.getCombinedStatusForRef({
      ...context.repo,
      ref: context.payload.pull_request.head.sha
    }).then(status => {
      if (status.data.statuses) {
        const statusPrefixToMatch = 'Container Image Published - ';

        return status.data.statuses.filter(status => {
          return status.context.startsWith(statusPrefixToMatch);
        });
      }
      return null;
    }).then(statuses => {
      return self.getContainers(statuses);
    })
  }

  async postNoContainerStatus() {
    const context = this.context;

    await this.github.issues.createComment({
      ...context.repo,
      issue_number: context.issue.number,
      body: `⚠️ Failed to trigger deployment request as missing container status check(s) on commit, did the container(s) build successfully?`,
    });
  }

  async postTooManyContainerStatus(containers) {
    const context = this.context;

    await this.github.issues.createComment({
      ...context.repo,
      issue_number: context.issue.number,
      body: `⚠️ Failed to trigger deployment request found too many containers on the commit:\n\n${JSON.stringify(containers)}`,
    });
  }

  getContainers(statuses) {
    const containers = [];

    statuses.forEach(status => {
      const nameParts = status.context.split(' - ')
        , containerType = nameParts[1].toLowerCase()
        , containerParts = status.description.split(':')
        ;

      containers.push({
        type: containerType,
        image: containerParts[0],
        version: containerParts[1]
      });
    });

    return containers;
  }

  // Extract the necessary details from the statuses to be able to create a deployment
  async postDeploymentComment(label, containers) {
    const context = this.context
      , github = this.github
      ;

    const environmentRegexResult = /deploy to (.*)/.exec(label)
      , containerTableEntries = []
      ;

    containers.forEach(container => {
      containerTableEntries.push(`| ${container.type} | _${container.image}_ | __${container.version}__ |`);
    });

    const commentBody = `
👋  Request from @${context.actor} for deployment received using _${label}_ :rocket:

Starting Deployment to environment __${environmentRegexResult[1]}__:
|Container|Image Name|Version|
|-|-|-|
${containerTableEntries.join('\n')}
`
    await github.issues.createComment({
      ...context.repo,
      issue_number: context.issue.number,
      body: commentBody,
    });
  }
}