package com.projeto.gerenciado_tarefas.controller;

import com.projeto.gerenciado_tarefas.dto.LoginRequest;
import com.projeto.gerenciado_tarefas.dto.LoginResponse;
import com.projeto.gerenciado_tarefas.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        return authService.login(request);
    }
}
