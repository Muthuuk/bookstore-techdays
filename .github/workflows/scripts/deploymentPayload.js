class DeploymentPayload {

  constructor(context, core, github) {
    this.context = context;
    this.core = core;
    this.github = github;
  }

  // Unpacks the deployment payload and sets them as outputs then reports a deployment status
  async unpackAndStart() {
    const context = this.context
      , github = this.github
      , core = this.core
      , run = process.env.GITHUB_RUN_ID
      , log_url = `https://github.com/${context.repo.owner}/${context.repo.repo}/actions/runs/${run}`
      ;

    const deployment = context.payload.deployment
      , environment = deployment.environment
      , deploymentPayload = JSON.parse(deployment.payload)
      , webAppName = `${context.repo.repo}-${environment}`
      ;

    core.startGroup('GitHub Context');
    core.info(JSON.stringify(context, null, 2));
    core.endGroup();

    core.startGroup('Outputs');
    this.setOutput('app_container_image', deploymentPayload.app_container.image);
    this.setOutput('app_container_version', deploymentPayload.app_container.version);

    this.setOutput('deployment_sha', deploymentPayload.sha);
    this.setOutput('deployment_github_ref', deploymentPayload.ref);

    this.setOutput('environment', environment);
    this.setOutput('webapp_name', webAppName);

    this.setOutput('container_registry', deploymentPayload.container_registry);

    this.setOutput('app_type', environment == 'prod' ? 'prod' : 'review');
    this.setOutput('app_slot_name', environment == 'prod' ? 'production' : environment);
    core.endGroup();

    github.repos.createDeploymentStatus({
      ...this.context.repo,
      mediaType: {
        previews: ["flash-preview", "ant-man"]
      },
      deployment_id: context.payload.deployment.id,
      state: 'in_progress',
      description: 'Deployment from GitHub Actions started',
      target_url: log_url,
      log_url: log_url
    });
  }

  async extractDeploymentDetails() {
    const context = this.context
      , core = this.core
      ;

    core.startGroup('GitHub Context');
    core.info(JSON.stringify(context, null, 2));
    core.endGroup();

    const deployment = context.payload.deployment
      , environment = deployment.environment
      , deploymentPayload = JSON.parse(deployment.payload)
      , webAppName = `${context.repo.repo}-${environment}`
      ;

    core.startGroup('Outputs');
    this.setOutput('deployment_sha', deploymentPayload.sha);
    this.setOutput('deployment_github_ref', deploymentPayload.ref);

    this.setOutput('environment', environment);
    this.setOutput('webapp_name', webAppName);

    this.setOutput('app_type', environment == 'prod' ? 'prod' : 'review');
    this.setOutput('app_slot_name', environment == 'prod' ? 'production' : environment);
    core.endGroup();
  }

  setOutput(name, value) {
    this.core.setOutput(name, value);
    this.core.info(`name:   ${name}`);
    this.core.info(`value:  ${value}`);
    this.core.info('');
  }
}

module.exports = (context, core, github) => {
  return new DeploymentPayload(context, core, github);
}
