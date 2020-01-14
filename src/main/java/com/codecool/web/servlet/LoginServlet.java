package com.codecool.web.servlet;

import com.codecool.web.dao.UserDao;
import com.codecool.web.dao.database.DatabaseUserDao;
import com.codecool.web.model.User;
import com.codecool.web.service.UserService;
import com.codecool.web.service.exception.ServiceException;
import com.codecool.web.service.simple.SimpleUserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;



@WebServlet("/login")
public final class LoginServlet extends AbstractServlet {

    private static Logger logger = LoggerFactory.getLogger(LoginServlet.class);
    private static Logger exceptionLogger = LoggerFactory.getLogger(LoginServlet.class);

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try (Connection connection = getConnection(req.getServletContext())) {
            UserDao userDao = new DatabaseUserDao(connection);
            UserService userService = new SimpleUserService(userDao);
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            User user = userService.loginUser(email, password);
            req.getSession().setAttribute("user", user);
            logger.info("Successfully logged in as user: " + email + ".");
            sendMessage(resp, HttpServletResponse.SC_OK, user);
        } catch (ServiceException ex) {
            logger.warn("Exception occurred while processing request - For more information see the exception log file.");
            logger.error("Service exception occurred at: ", ex);
            sendMessage(resp, HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (SQLException ex) {
            logger.warn("Exception occurred while processing request - For more information see the exception log file.");
            logger.error("SQL exception occurred at: ", ex);
            handleSqlError(resp, ex);
        }
    }
}
