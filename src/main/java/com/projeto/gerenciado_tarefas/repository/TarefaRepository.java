package com.projeto.gerenciado_tarefas.repository;

import com.projeto.gerenciado_tarefas.entity.Tarefa;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface TarefaRepository extends JpaRepository<Tarefa, String> {

    List<Tarefa> findByListaIdLista(String idLista);

    List<Tarefa> findByResponsavelIdUsuario(String idUsuario);

    @Query(value = "SELECT fn_gerar_id_tarefa()", nativeQuery = true)
    String gerarIdTarefa();
}
