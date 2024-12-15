package io.ws.fast.test;

import com.hummer.core.ApplicationContextInitBean;
import com.hummer.core.init.HummerApplicationContextInit;
import com.hummer.dao.starter.ExportDaoInitBean;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.ConfigDataApplicationContextInitializer;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.PropertySource;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;

@RunWith(value = SpringRunner.class)
@Import(value = {ApplicationContextInitBean.class, ExportDaoInitBean.class})
@ContextConfiguration(initializers =
        {ConfigDataApplicationContextInitializer.class, HummerApplicationContextInit.class})
@ComponentScan(basePackages = "io.ws.fast")
@PropertySource({"classpath:application.properties","classpath:application-dev.properties"})
//If using the hummer rest client wrapper framework, enable this configuration
//@HummerRestApiClientBootScan(scanBasePackages = "xx")
@WebAppConfiguration
public class BaseTest {
    @Test
    public void bootstrap() {

    }
}