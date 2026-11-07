/* ==========================================================================
   Projeto : Projeto Lógico de Banco de Dados – Oficina Mecânica (DIO)
   Script  : 03_queries_negocio.sql
   Objetivo: Consultas que respondem perguntas de negócio
   SGBD    : PostgreSQL 14+
   Autor   : Deusdedit Andrade da Silva Junior
   --------------------------------------------------------------------------
   Cláusulas exigidas no desafio e onde aparecem:
     SELECT simples ........................ Q1
     Filtros com WHERE ..................... Q2, Q3
     Atributos derivados ................... Q4, Q5, Q6
     ORDER BY .............................. Q7 (e na maioria das demais)
     GROUP BY + HAVING ..................... Q8, Q9, Q10
     JOINs entre tabelas ................... Q4 a Q6 e Q9 a Q16
   Validação do modelo ..................... Q17
   Dica DBeaver: posicione o cursor na consulta e use Ctrl + Enter.
   ========================================================================== */

SET search_path TO oficina;

-- ==========================================================================
-- 1. SELECT SIMPLES
-- ==========================================================================

-- Q1. Quais veículos estão cadastrados?
SELECT id_veiculo, placa, marca, modelo, ano
FROM veiculo;

-- ==========================================================================
-- 2. FILTROS COM WHERE
-- ==========================================================================

-- Q2. Quais OS estão paradas esperando o cliente autorizar o orçamento?
SELECT numero_os, id_veiculo, data_emissao, data_prevista_conclusao
FROM ordem_servico
WHERE status_os = 'AGUARDANDO_AUTORIZACAO';

-- Q3. Quais serviços da tabela de mão de obra custam entre R$ 100 e R$ 400?
SELECT descricao, valor_mao_de_obra
FROM servico
WHERE valor_mao_de_obra BETWEEN 100 AND 400;

-- ==========================================================================
-- 3. ATRIBUTOS DERIVADOS (expressões calculadas)
-- ==========================================================================

-- Q4. Qual o valor total de cada OS?
-- O "ValorTotal" do modelo conceitual não é armazenado: é derivado aqui.
-- Serviços e peças são somados em CTEs separadas ANTES do JOIN; juntar as
-- duas tabelas direto multiplicaria as linhas e inflaria os totais.
WITH total_servicos AS (
    SELECT id_os, SUM(quantidade * valor_unitario) AS valor_servicos
    FROM os_servico
    GROUP BY id_os
),
total_pecas AS (
    SELECT id_os, SUM(quantidade * valor_unitario) AS valor_pecas
    FROM os_peca
    GROUP BY id_os
)
SELECT
    os.numero_os,
    os.status_os,
    COALESCE(ts.valor_servicos, 0)                                AS valor_mao_de_obra,
    COALESCE(tp.valor_pecas, 0)                                   AS valor_pecas,
    COALESCE(ts.valor_servicos, 0) + COALESCE(tp.valor_pecas, 0)  AS valor_total
FROM ordem_servico os
LEFT JOIN total_servicos ts ON ts.id_os = os.id_os
LEFT JOIN total_pecas    tp ON tp.id_os = os.id_os
ORDER BY os.numero_os;

-- Q5. As OS concluídas cumpriram o prazo prometido ao cliente?
SELECT
    numero_os,
    data_emissao,
    data_prevista_conclusao,
    data_conclusao,
    data_conclusao - data_emissao                        AS dias_na_oficina,
    data_conclusao - data_prevista_conclusao             AS dias_de_atraso,
    CASE WHEN data_conclusao <= data_prevista_conclusao
         THEN 'No prazo' ELSE 'Atrasada' END             AS situacao_prazo
FROM ordem_servico
WHERE status_os = 'CONCLUIDA'
ORDER BY dias_de_atraso DESC;

-- Q6. Desconto concedido em cada serviço em relação à tabela de mão de obra.
SELECT
    os.numero_os,
    s.descricao,
    oss.quantidade,
    s.valor_mao_de_obra                                         AS preco_tabela,
    oss.valor_unitario                                          AS preco_praticado,
    oss.quantidade * (s.valor_mao_de_obra - oss.valor_unitario) AS desconto_total,
    ROUND(100 * (1 - oss.valor_unitario / s.valor_mao_de_obra), 1) AS desconto_percentual
FROM os_servico oss
JOIN servico       s  ON s.id_servico = oss.id_servico
JOIN ordem_servico os ON os.id_os     = oss.id_os
WHERE oss.valor_unitario < s.valor_mao_de_obra
ORDER BY desconto_total DESC;

-- ==========================================================================
-- 4. ORDENAÇÃO COM ORDER BY
-- ==========================================================================

-- Q7. Veículos do mais novo para o mais antigo, com a idade calculada.
SELECT
    placa,
    marca || ' ' || modelo                        AS veiculo,
    ano,
    EXTRACT(YEAR FROM CURRENT_DATE)::INT - ano    AS idade_anos
FROM veiculo
ORDER BY ano DESC, marca, modelo;

-- ==========================================================================
-- 5. AGRUPAMENTO COM GROUP BY + HAVING
-- ==========================================================================

-- Q8. Quais clientes têm mais de um veículo cadastrado?
SELECT
    c.nome,
    c.tipo_cliente,
    COUNT(v.id_veiculo)                              AS qtd_veiculos,
    string_agg(v.placa, ', ' ORDER BY v.placa)       AS placas
FROM cliente c
JOIN veiculo v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome, c.tipo_cliente
HAVING COUNT(v.id_veiculo) > 1
ORDER BY qtd_veiculos DESC;

-- Q9. Quais veículos voltaram à oficina mais de uma vez (sem contar cancelamentos)?
SELECT
    v.placa,
    v.marca || ' ' || v.modelo                                       AS veiculo,
    COUNT(os.id_os)                                                  AS qtd_os,
    string_agg(DISTINCT e.nome_equipe, ', ')                         AS equipes_que_atenderam
FROM veiculo v
JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
JOIN equipe        e  ON e.id_equipe   = os.id_equipe
WHERE os.status_os <> 'CANCELADA'
GROUP BY v.id_veiculo, v.placa, v.marca, v.modelo
HAVING COUNT(os.id_os) > 1
ORDER BY qtd_os DESC;

-- Q10. Quais equipes faturaram mais de R$ 3.000 em OS concluídas?
WITH valor_os AS (
    SELECT id_os, SUM(quantidade * valor_unitario) AS valor FROM os_servico GROUP BY id_os
    UNION ALL
    SELECT id_os, SUM(quantidade * valor_unitario)          FROM os_peca    GROUP BY id_os
)
SELECT
    e.codigo_equipe,
    e.nome_equipe,
    COUNT(DISTINCT os.id_os)  AS os_concluidas,
    SUM(vo.valor)             AS faturamento
FROM equipe e
JOIN ordem_servico os ON os.id_equipe = e.id_equipe
JOIN valor_os      vo ON vo.id_os     = os.id_os
WHERE os.status_os = 'CONCLUIDA'
GROUP BY e.id_equipe, e.codigo_equipe, e.nome_equipe
HAVING SUM(vo.valor) > 3000
ORDER BY faturamento DESC;

-- ==========================================================================
-- 6. JOINS – PERGUNTAS DE NEGÓCIO
-- ==========================================================================

-- Q11. Histórico completo de um veículo: quais OS, quando e com qual equipe?
-- Mostra por que a equipe fica na OS: o mesmo carro foi atendido por
-- equipes diferentes em visitas diferentes.
SELECT
    v.placa,
    c.nome          AS cliente,
    os.numero_os,
    os.tipo_os,
    os.status_os,
    os.data_emissao,
    e.nome_equipe   AS equipe,
    os.observacao
FROM veiculo v
JOIN cliente       c  ON c.id_cliente = v.id_cliente
JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
JOIN equipe        e  ON e.id_equipe   = os.id_equipe
WHERE v.placa = 'ABC1D23'
ORDER BY os.data_emissao;

-- Q12. Composição das equipes: mecânicos e especialidades.
SELECT
    e.codigo_equipe,
    e.nome_equipe,
    COUNT(m.id_mecanico)                                                AS qtd_mecanicos,
    string_agg(m.nome || ' (' || m.especialidade || ')', ', ' ORDER BY m.nome) AS mecanicos
FROM equipe e
JOIN mecanico m ON m.id_equipe = e.id_equipe
WHERE m.ativo
GROUP BY e.id_equipe, e.codigo_equipe, e.nome_equipe
ORDER BY e.codigo_equipe;

-- Q13. OS em aberto com dados de contato do cliente, para o atendimento ligar.
SELECT
    os.numero_os,
    os.status_os,
    os.data_prevista_conclusao,
    CASE WHEN os.data_prevista_conclusao < CURRENT_DATE
         THEN 'ATRASADA' ELSE 'No prazo' END    AS alerta_prazo,
    c.nome                                      AS cliente,
    c.telefone,
    v.placa,
    v.marca || ' ' || v.modelo                  AS veiculo,
    e.nome_equipe                               AS equipe
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
JOIN cliente c ON c.id_cliente = v.id_cliente
JOIN equipe  e ON e.id_equipe  = os.id_equipe
WHERE os.status_os NOT IN ('CONCLUIDA', 'CANCELADA')
ORDER BY os.data_prevista_conclusao;

-- Q14. Quais peças mais saem nas OS concluídas? Peças nunca usadas também aparecem.
WITH uso_pecas AS (
    SELECT op.id_peca,
           SUM(op.quantidade)                    AS unidades,
           SUM(op.quantidade * op.valor_unitario) AS receita
    FROM os_peca op
    JOIN ordem_servico os ON os.id_os = op.id_os
    WHERE os.status_os = 'CONCLUIDA'
    GROUP BY op.id_peca
)
SELECT
    p.nome_peca,
    COALESCE(u.unidades, 0)  AS unidades_utilizadas,
    COALESCE(u.receita, 0)   AS receita
FROM peca p
LEFT JOIN uso_pecas u ON u.id_peca = p.id_peca
ORDER BY unidades_utilizadas DESC, p.nome_peca;

-- Q15. Quanto cada cliente já gastou na oficina (OS concluídas)?
-- LEFT JOIN em cadeia para incluir clientes que ainda não gastaram nada.
WITH valor_os AS (
    SELECT os.id_os, os.id_veiculo,
           COALESCE((SELECT SUM(quantidade * valor_unitario) FROM os_servico s WHERE s.id_os = os.id_os), 0)
         + COALESCE((SELECT SUM(quantidade * valor_unitario) FROM os_peca    p WHERE p.id_os = os.id_os), 0) AS valor
    FROM ordem_servico os
    WHERE os.status_os = 'CONCLUIDA'
)
SELECT
    c.nome,
    c.tipo_cliente,
    COUNT(vo.id_os)              AS os_concluidas,
    COALESCE(SUM(vo.valor), 0)   AS total_gasto,
    ROUND(AVG(vo.valor), 2)      AS ticket_medio
FROM cliente c
LEFT JOIN veiculo  v  ON v.id_cliente  = c.id_cliente
LEFT JOIN valor_os vo ON vo.id_veiculo = v.id_veiculo
GROUP BY c.id_cliente, c.nome, c.tipo_cliente
ORDER BY total_gasto DESC;

-- Q16. Peso da mão de obra e das peças no faturamento por tipo de OS.
WITH servicos AS (
    SELECT os.tipo_os, SUM(s.quantidade * s.valor_unitario) AS valor
    FROM os_servico s JOIN ordem_servico os ON os.id_os = s.id_os
    WHERE os.status_os = 'CONCLUIDA'
    GROUP BY os.tipo_os
),
pecas AS (
    SELECT os.tipo_os, SUM(p.quantidade * p.valor_unitario) AS valor
    FROM os_peca p JOIN ordem_servico os ON os.id_os = p.id_os
    WHERE os.status_os = 'CONCLUIDA'
    GROUP BY os.tipo_os
)
SELECT
    s.tipo_os,
    s.valor                                           AS mao_de_obra,
    p.valor                                           AS pecas,
    s.valor + p.valor                                 AS total,
    ROUND(100 * s.valor / (s.valor + p.valor), 1)     AS perc_mao_de_obra,
    ROUND(100 * p.valor / (s.valor + p.valor), 1)     AS perc_pecas
FROM servicos s
JOIN pecas    p ON p.tipo_os = s.tipo_os
ORDER BY total DESC;

-- ==========================================================================
-- 7. VALIDAÇÃO DO MODELO
-- ==========================================================================

-- Q17. Quais constraints o banco garante? (lidas do catálogo do PostgreSQL)
SELECT
    c.relname                          AS tabela,
    k.conname                          AS constraint_nome,
    CASE k.contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
    END                                AS tipo,
    pg_get_constraintdef(k.oid)        AS definicao
FROM pg_constraint k
JOIN pg_class      c ON c.oid = k.conrelid
JOIN pg_namespace  n ON n.oid = c.relnamespace
WHERE n.nspname = 'oficina'
  AND k.contype IN ('p', 'f', 'u', 'c')
ORDER BY c.relname, k.contype, k.conname;
