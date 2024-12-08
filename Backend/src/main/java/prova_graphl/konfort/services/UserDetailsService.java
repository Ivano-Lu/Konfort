package prova_graphl.konfort.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import prova_graphl.konfort.models.dao.User;
import prova_graphl.konfort.repositories.UserRepository;

@Service
public class UserDetailsService {

    private final UserRepository userRepository;

    @Autowired
    public UserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User addUser(String name, String surname, String email, String password){
        User user = new User();
        user.setName(name);
        user.setSurname(surname);
        user.setEmail(email);
        user.setPassword(password);
        return userRepository.save(user);
    }

    public User getUserById(Long id){
        return userRepository.findById(id).orElse(null);
    }

    public User getUserByEmail(String email){
        return userRepository.findByEmail(email);
    }

    public boolean checkPassword(User user, String password){
        return user.getPassword().equals(password);
    }

}
