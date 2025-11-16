package com.projeto.gerenciado_tarefas.repository;

import com.projeto.gerenciado_tarefas.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, String> {

    Optional<Usuario> findByEmailAndSenhaHashAndAtivoTrue(String email, String senhaHash);

    @Query(value = "SELECT fn_gerar_id_usuario()", nativeQuery = true)
    String gerarIdUsuario();
}
