package com.projeto.gerenciado_tarefas.repository;

import com.projeto.gerenciado_tarefas.entity.GrupoUsuario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GrupoUsuarioRepository extends JpaRepository<GrupoUsuario, String> {
}
