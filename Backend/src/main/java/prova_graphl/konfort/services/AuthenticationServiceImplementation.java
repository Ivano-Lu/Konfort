package prova_graphl.konfort.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import prova_graphl.konfort.models.dao.Session;
import prova_graphl.konfort.models.dao.User;
import prova_graphl.konfort.models.dto.LoginResponse;
import prova_graphl.konfort.models.dto.CalibrationDataPayload;
import prova_graphl.konfort.repositories.SessionRepository;
import prova_graphl.konfort.utils.JwtTokenUtil;

import java.util.Optional;

@Service
public class AuthenticationServiceImplementation implements AuthenticationService {

    @Autowired
    private final UserDetailsService userDetailsService;

    @Autowired
    private final SessionRepository sessionRepository;

    @Autowired
    private final CalibrationDataService calibrationDataService;

    public AuthenticationServiceImplementation(UserDetailsService userDetailsService, JwtTokenUtil jwtTokenUtil, SessionRepository sessionRepository, CalibrationDataService calibrationDataService) {
        this.userDetailsService = userDetailsService;
        this.sessionRepository = sessionRepository;
        this.calibrationDataService = calibrationDataService;
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

        // Fetch calibration data if available
        CalibrationDataPayload calibrationData = null;
        try {
            Optional<prova_graphl.konfort.models.dao.CalibrationData> calibData = calibrationDataService.getCalibrationDataByUserId(user.getId());
            if (calibData.isPresent()) {
                calibrationData = calibrationDataService.mapToPayload(calibData.get());
                System.out.println("✅ Calibration data found for user " + user.getId());
            } else {
                System.out.println("ℹ️ No calibration data found for user " + user.getId());
            }
        } catch (Exception e) {
            // Log error but don't fail login if calibration data is not available
            System.out.println("⚠️ Warning: Could not fetch calibration data for user " + user.getId() + ": " + e.getMessage());
            // Continue with login without calibration data
        }

        return new LoginResponse(accessToken, refreshToken, user.getId(), calibrationData);
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

                return new LoginResponse(newAccessToken, newRefreshToken, session.getUser().getId(), null);
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
