package com.projeto.gerenciado_tarefas.service;

import com.projeto.gerenciado_tarefas.dto.LoginRequest;
import com.projeto.gerenciado_tarefas.dto.LoginResponse;
import com.projeto.gerenciado_tarefas.entity.Usuario;
import com.projeto.gerenciado_tarefas.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;

    public LoginResponse login(LoginRequest request) {

        // senha simples (ideal: hash real)
        String senhaHash = request.getSenha();

        Usuario usuario = usuarioRepository
                .findByEmailAndSenhaHashAndAtivoTrue(request.getEmail(), senhaHash)
                .orElse(null);

        if (usuario == null) {
            return null;
        }

        return new LoginResponse(
                usuario.getIdUsuario(),
                usuario.getNome(),
                usuario.getGrupo().getNome()
        );
    }
}
