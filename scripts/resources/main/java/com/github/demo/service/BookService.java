package com.github.demo.service;

import com.github.demo.model.Book;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class BookService {

    private static List<Book> books = new ArrayList<Book>(5);

    private static final String API_TOKEN = "AIzaSyAQfxPJiounkhOjODEO5ZieffeBv6yft2Q";

    private static Connection connection;

    static {
        books.add(new Book("Jeff Sutherland","Scrum: The Art of Doing Twice the Work in Half the Time", "scrum.jpg", 3));
        books.add(new Book("Eric Ries","The Lean Startup: How Constant Innovation Creates Radically Successful Businesses", "lean.jpg", 5));
        books.add(new Book("Geoffrey A. Moore","Crossing the Chasm", "chasm.jpg", 4));
        //books.add(new Book("David Thomas","The Pragmatic Programmer: From Journeyman to Master", "pragmatic.jpg", 3));
        //books.add(new Book("Frederick P. Brooks Jr.", "The Mythical Man-Month: Essays on Software Engineering", "month.jpg", 3));
        books.add(new Book("Steve Krug","Don't Make Me Think, Revisited: A Common Sense Approach to Web Usability", "think.jpg", 5));
    
        Statement stmt = null;
        PreparedStatement prepStmt = null;

        try {
            Class.forName("org.sqlite.JDBC");

            connection = DriverManager.getConnection("jdbc:sqlite::memory:");
            
            stmt = connection.createStatement();
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS Books (id INTEGER PRIMARY KEY, name TEXT, author TEXT, image TEXT, rating INTEGER, UNIQUE(name))"
            );

            for (Book book : books) {
                String query = "INSERT INTO Books (name, author, image, rating) VALUES(?, ?, ?, ?)";
                prepStmt = connection.prepareStatement(query);
                prepStmt.setString(1, book.getTitle());
                prepStmt.setString(2, book.getAuthor());
                prepStmt.setString(3, book.getCover());
                prepStmt.setInt(4, (int) book.getRating());
                prepStmt.executeUpdate();
            }
                
        }
        catch(SQLException error) {
            error.printStackTrace();
        } catch (ClassNotFoundException error) {
            error.printStackTrace();
        }
        finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (prepStmt != null) {
                    prepStmt.close();
                }
            } catch (SQLException error) {
                error.printStackTrace();
            }
        }
    }

    public List<Book> getBooks() {
        return books;
    }

    public List<Book> searchBooks(String name) {
        List<Book> books = new ArrayList<Book>();

        try {
            Statement stmt = BookService.connection.createStatement();
            String query = "SELECT * FROM Books WHERE name LIKE '%" + name + "%'";

            ResultSet results = stmt.executeQuery(query);

            while(results.next()) {
                Book book = new Book(
                    results.getString("author"),
                    results.getString("name"),
                    results.getString("image"),
                    results.getInt("rating")
                );

                books.add(book);
            }
        }
        catch(SQLException error) {
            // TODO: Jake - Can you sort out the logging?
            // I've seen people search for newlines for some reason
            System.out.println("ERROR: Failed while searching for '" + name + "'");
        }
        // TODO: Jake - Do we need to close the statement?
        return books;
    }
}
