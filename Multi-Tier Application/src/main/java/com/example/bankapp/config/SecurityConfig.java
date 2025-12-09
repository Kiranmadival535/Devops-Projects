package com.example.bankapp.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Value("${APP_USER:admin}")
    private String appUser;

    @Value("${APP_PASS:password}")
    private String appPass;

    @Bean
    public UserDetailsService users() {
        var user = User.withDefaultPasswordEncoder()
                .username(appUser)
                .password(appPass)
                .roles("ACTUATOR")
                .build();
        return new InMemoryUserDetailsManager(user);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http.csrf(csrf -> csrf.disable());

        http.authorizeHttpRequests(authorize -> authorize
                // allow k8s probes
                .requestMatchers("/actuator/health", "/actuator/health/**").permitAll()
                // protect all other actuator endpoints
                .requestMatchers("/actuator/**").hasRole("ACTUATOR")
                // your UI pages remain public
                .anyRequest().permitAll()
        );

        // basic auth for protected actuator endpoints
        http.httpBasic(Customizer.withDefaults());

        // disable login form
        http.formLogin(form -> form.disable());

        return http.build();
    }
}
