package prova_graphl.konfort.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import prova_graphl.konfort.models.dao.Session;
import prova_graphl.konfort.models.dao.User;
import prova_graphl.konfort.models.dto.LoginResponse;
import prova_graphl.konfort.repositories.SessionRepository;
import prova_graphl.konfort.utils.JwtTokenUtil;

import java.util.Optional;

@Service
public class AuthenticationServiceImplementation implements AuthenticationService {

    @Autowired
    private final UserDetailsService userDetailsService;

    @Autowired
    private final SessionRepository sessionRepository;

    public AuthenticationServiceImplementation(UserDetailsService userDetailsService, JwtTokenUtil jwtTokenUtil, SessionRepository sessionRepository) {
        this.userDetailsService = userDetailsService;
        this.sessionRepository = sessionRepository;
    }

    @Override
    public LoginResponse login(String email, String password) throws Exception {
        //Retrieve the user by email
        User user = userDetailsService.getUserByEmail(email);
        if (user == null){
            throw new RuntimeException("User not found");
        }

        if (!userDetailsService.checkPassword(user, password)){
            throw new RuntimeException("invalid password");
        }

        String accessToken = JwtTokenUtil.generateToken(email);
        String refreshToken = JwtTokenUtil.generateRefreshToken(email);

        Session session = new Session();
        session.setUser(user);
        session.setAccessToken(accessToken);
        session.setRefreshToken(refreshToken);
        sessionRepository.save(session);

        return new LoginResponse(accessToken, refreshToken, user.getId());
    }

    @Override
    public LoginResponse refresh(String refreshToken) throws Exception {
        Optional<Session> sessionOptional = sessionRepository.findByRefreshToken(refreshToken);
        if (sessionOptional.isPresent()){
            Session session = sessionOptional.get();
            if (!session.isRefreshTokenUsed()){
                session.setRefreshTokenUsed(true);
                sessionRepository.save(session);

                String newAccessToken = JwtTokenUtil.generateToken(session.getUser().getEmail());
                String newRefreshToken = JwtTokenUtil.generateRefreshToken(session.getUser().getEmail());

                Session newSession = new Session();
                newSession.setAccessToken(newAccessToken);
                newSession.setRefreshToken(newRefreshToken);
                sessionRepository.save(newSession);

                return new LoginResponse(newAccessToken, newRefreshToken, 0L);
            }
            else {
                throw  new RuntimeException("Refresh token already used");
            }
        }
        else {
            throw new RuntimeException("Invalid refresh token");
        }
    }
}
