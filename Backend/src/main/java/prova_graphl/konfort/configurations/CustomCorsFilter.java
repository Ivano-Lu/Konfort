package prova_graphl.konfort.configurations;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Configuration;
import prova_graphl.konfort.utils.CachedBodyHttpServletRequest;
import prova_graphl.konfort.utils.GraphQLUtil;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Configuration
public class CustomCorsFilter implements Filter {



    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        Filter.super.init(filterConfig);
    }

    @Override
    public void destroy() {
        Filter.super.destroy();
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) servletRequest;
        HttpServletResponse res = (HttpServletResponse) servletResponse;

        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "*");
        res.setHeader("Access-Control-Allow-Headers", "*");
        res.setHeader("Access-Control-Expose-Headers", "*");
        res.setHeader("Access-Control-Max-Age", "3600");

        req.getHeader("Authorization");


        // if the token is valid and not expired
//        if (jwtTokenUtil.isTokenExpired(req.getHeader("Authorization"))) {
//            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
//            return;
//        }


        CachedBodyHttpServletRequest cachedBodyHttpServletRequest = new CachedBodyHttpServletRequest(req);
        String body = new String(cachedBodyHttpServletRequest.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        System.out.println("request name: " + GraphQLUtil.extractOperationName(body));
        System.out.println(body);



        if (req.getMethod().equals("OPTIONS"))
            res.setStatus(HttpServletResponse.SC_OK);
        else
            filterChain.doFilter(cachedBodyHttpServletRequest, res);
    }

}
