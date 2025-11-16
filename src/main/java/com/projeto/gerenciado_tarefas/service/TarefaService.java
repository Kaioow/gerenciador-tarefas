package com.projeto.gerenciado_tarefas.service;

import com.projeto.gerenciado_tarefas.entity.LogTarefa;
import com.projeto.gerenciado_tarefas.entity.Tarefa;
import com.projeto.gerenciado_tarefas.repository.LogTarefaRepository;
import com.projeto.gerenciado_tarefas.repository.TarefaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TarefaService {

    private final TarefaRepository tarefaRepository;
    private final LogTarefaRepository logRepository;

    public List<Tarefa> listar() {
        return tarefaRepository.findAll();
    }

    public Tarefa criar(Tarefa tarefa) {
        String novoId = tarefaRepository.gerarIdTarefa();
        tarefa.setIdTarefa(novoId);
        tarefa.setDataCriacao(LocalDateTime.now());

        Tarefa salva = tarefaRepository.save(tarefa);

        registrarLog(salva.getIdTarefa(),
                "CRIAR_TAREFA",
                null,
                salva.getStatus(),
                "WEB",
                "Tarefa criada.");

        return salva;
    }

    public Tarefa atualizar(String id, Tarefa atualizada) {
        Tarefa existente = tarefaRepository.findById(id).orElse(null);
        if (existente == null) return null;

        String statusAnterior = existente.getStatus();

        existente.setTitulo(atualizada.getTitulo());
        existente.setDescricao(atualizada.getDescricao());
        existente.setPrioridade(atualizada.getPrioridade());
        existente.setStatus(atualizada.getStatus());
        existente.setDataLimite(atualizada.getDataLimite());
        existente.setResponsavel(atualizada.getResponsavel());

        Tarefa salva = tarefaRepository.save(existente);

        registrarLog(id, "ALTERAR_STATUS", statusAnterior, salva.getStatus(), "WEB",
                "Tarefa atualizada.");

        return salva;
    }

    public void excluir(String id) {
        tarefaRepository.deleteById(id);

        registrarLog(id, "EXCLUIR_TAREFA", null, null, "WEB",
                "Tarefa excluída.");
    }

    private void registrarLog(String idTarefa, String acao, String anterior, String novo,
                              String origem, String detalhes) {

        LogTarefa log = new LogTarefa();
        log.setIdTarefa(idTarefa);
        log.setAcao(acao);
        log.setStatusAnterior(anterior);
        log.setStatusNovo(novo);
        log.setOrigem(origem);
        log.setDetalhes(detalhes);
        log.setDataHora(LocalDateTime.now());

        logRepository.save(log);
    }
}
