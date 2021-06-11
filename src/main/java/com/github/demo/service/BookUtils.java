package com.github.demo.service;

import java.util.ArrayList;
import java.util.List;

import com.github.demo.model.Book;

public class BookUtils {

    public static List<Book> getSampleBooks() {
        List<Book> books = new ArrayList<Book>(6);

        books.add(new Book("Jeff Sutherland", "Scrum: The Art of Doing Twice the Work in Half the Time", "scrum.jpg", 5));
        books.add(new Book("Eric Ries", "The Lean Startup: How Constant Innovation Creates Radically Successful Businesses", "lean.jpg", 2));
        books.add(new Book("Geoffrey A. Moore", "Crossing the Chasm", "chasm.jpg", 4));
        books.add(new Book("David Thomas", "The Pragmatic Programmer: From Journeyman to Master", "pragmatic.jpg", 1));
        books.add(new Book("Frederick P. Brooks Jr.", "The Mythical Man-Month: Essays on Software Engineering", "month.jpg", 5));
        books.add(new Book("Steve Krug", "Don't Make Me Think, Revisited: A Common Sense Approach to Web Usability", "think.jpg", 3));

        return books;
    }
}
