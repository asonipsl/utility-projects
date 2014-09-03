package com.mcent.utility.web;

import java.net.URL;
import java.security.ProtectionDomain;

import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Handler;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.handler.DefaultHandler;
import org.mortbay.jetty.handler.HandlerCollection;
import org.mortbay.jetty.nio.SelectChannelConnector;
import org.mortbay.jetty.webapp.WebAppContext;
import org.mortbay.thread.QueuedThreadPool;

/**
 * @author pankaj_mokati,abhishek_soni
 *
 */
public class WebAppHost {

    public static void main(String[] args) throws Exception {

        Server server = new Server();
        Connector connector = new SelectChannelConnector();

        // Set some timeout options to make debugging easier.
        // connector.setMaxIdleTime(1000 * 60 * 60);
        connector.setPort(8080);
        server.setConnectors(new Connector[] { connector });

        WebAppContext context = new WebAppContext();
        context.setServer(server);
        context.setContextPath("/myAppContext");

        ProtectionDomain protectionDomain = WebAppHost.class
                .getProtectionDomain();
        URL location = protectionDomain.getCodeSource().getLocation();
        context.setWar(location.toExternalForm());

        HandlerCollection handlers = new HandlerCollection();
        handlers.setHandlers(new Handler[] { context, new DefaultHandler() });

        // context.setDescriptor(location.toExternalForm() +
        // "/WEB-INF/web.xml");

        server.addHandler(handlers);

        QueuedThreadPool threadPool = new QueuedThreadPool(1000);
        server.setThreadPool(threadPool);


        try {

            server.start();
            // System.in.read();
            // server.stop();
            server.join();

        } catch (Exception e) {

            e.printStackTrace();
            System.exit(100);

        }
    }

}