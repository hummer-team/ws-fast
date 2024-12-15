package io.ws.fast.api.main;

import com.hummer.core.starter.HummerApplicationStart;
import com.hummer.rest.webserver.UndertowServer;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

/**
 * application enter
 *
 * @Author liguo
 * @Copyright 20219
 **/
@SpringBootApplication(scanBasePackages = "io.ws.fast", exclude = {DataSourceAutoConfiguration.class})
@EnableAspectJAutoProxy(proxyTargetClass = true)
@UndertowServer
public class ApplicationStart {
    public static void main(String[] args) {
        HummerApplicationStart.start(ApplicationStart.class, args);
    }
}
