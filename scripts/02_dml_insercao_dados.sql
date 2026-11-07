/* ==========================================================================
   Projeto : Projeto Lógico de Banco de Dados – Oficina Mecânica (DIO)
   Script  : 02_dml_insercao_dados.sql
   Objetivo: Carga de dados fictícios para testar o modelo (DML)
   SGBD    : PostgreSQL 14+
   Autor   : Deusdedit Andrade da Silva Junior
   --------------------------------------------------------------------------
   Pré-requisito: executar antes o 01_ddl_criacao_tabelas.sql.
   Os IDs são gerados pela IDENTITY na ordem de inserção (1, 2, 3...),
   por isso as tabelas associativas referenciam esses números.
   Todos os documentos, placas e dados pessoais são fictícios.
   ========================================================================== */

SET search_path TO oficina;

-- --------------------------------------------------------------------------
-- CLIENTES (5 PF e 3 PJ)
-- --------------------------------------------------------------------------
INSERT INTO cliente (tipo_cliente, nome, cpf, cnpj, telefone, email, logradouro, cidade, uf, cep, data_cadastro) VALUES
('PF', 'José Ribamar Costa',          '11122233344', NULL,             '98991230001', 'jose.costa@email.com',         'Rua do Passeio, 210',        'São Luís', 'MA', '65015370', '2026-03-12 09:00'),  -- 1
('PF', 'Maria das Graças Pereira',    '22233344455', NULL,             '98991230002', 'maria.pereira@email.com',      'Av. Colares Moreira, 1500',  'São Luís', 'MA', '65075441', '2026-04-02 14:30'),  -- 2
('PF', 'Antônio Carlos Nunes',        '33344455566', NULL,             '98991230003', NULL,                           'Rua dos Afogados, 88',       'São Luís', 'MA', '65010020', '2026-04-20 10:15'),  -- 3
('PF', 'Luciana Martins Rocha',       '44455566677', NULL,             '98991230004', 'luciana.rocha@email.com',      'Av. Daniel de La Touche, 30','São Luís', 'MA', '65076000', '2026-05-15 16:45'),  -- 4
('PF', 'Paulo Henrique Sousa',        '55566677788', NULL,             '98991230005', 'paulo.sousa@email.com',        'Rua Rio Branco, 402',        'São Luís', 'MA', '65020370', '2026-06-01 08:20'),  -- 5
('PJ', 'Transportes Ilha Bela Ltda',  NULL,          '12345678000190', '9832140006',  'frota@ilhabela.com.br',        'Av. dos Portugueses, 5000',  'São Luís', 'MA', '65085580', '2026-02-10 11:00'),  -- 6
('PJ', 'Farmácia Saúde Total Ltda',   NULL,          '23456789000101', '9832140007',  'compras@saudetotal.com.br',    'Rua Grande, 650',            'São Luís', 'MA', '65020250', '2026-03-28 13:40'),  -- 7
('PJ', 'Construtora Alicerce Ltda',   NULL,          '34567890000112', '9832140008',  'manutencao@alicerce.com.br',   'Av. Jerônimo de Albuquerque, 900', 'São Luís', 'MA', '65060645', '2026-05-05 15:10'); -- 8

-- --------------------------------------------------------------------------
-- VEÍCULOS (cliente 1 tem dois; a transportadora tem uma frota de três;
-- o veículo 6 nunca passou pela oficina)
-- --------------------------------------------------------------------------
INSERT INTO veiculo (id_cliente, placa, marca, modelo, ano) VALUES
(1, 'ABC1D23', 'Fiat',          'Strada',   2020),  -- 1
(1, 'PQR4567', 'Honda',         'Civic',    2015),  -- 2
(2, 'HZK2B45', 'Hyundai',       'HB20',     2022),  -- 3
(3, 'NMA8812', 'Toyota',        'Corolla',  2018),  -- 4
(4, 'ROC3E77', 'Renault',       'Kwid',     2023),  -- 5
(5, 'PHS9A10', 'Chevrolet',     'Onix',     2021),  -- 6
(6, 'TIB1A01', 'Mercedes-Benz', 'Accelo',   2019),  -- 7
(6, 'TIB2B02', 'Volkswagen',    'Delivery', 2020),  -- 8
(6, 'TIB3C03', 'Ford',          'Cargo',    2017),  -- 9
(7, 'FST4D44', 'Fiat',          'Fiorino',  2021),  -- 10
(8, 'CAL5E55', 'Toyota',        'Hilux',    2022);  -- 11

-- --------------------------------------------------------------------------
-- EQUIPES E MECÂNICOS
-- --------------------------------------------------------------------------
INSERT INTO equipe (codigo_equipe, nome_equipe) VALUES
('EQ-01', 'Motor e Transmissão'),   -- 1
('EQ-02', 'Suspensão e Freios'),    -- 2
('EQ-03', 'Elétrica e Revisão');    -- 3

INSERT INTO mecanico (id_equipe, codigo, nome, especialidade, logradouro, cidade, uf, cep) VALUES
(1, 'MEC-001', 'Raimundo Nonato Silva',    'MOTOR',           'Rua 7, 45 - Cohab',              'São Luís',        'MA', '65051130'),
(1, 'MEC-002', 'Francisco Alves Lima',     'TRANSMISSAO',     'Rua 12, 300 - Cohatrac',         'São Luís',        'MA', '65054080'),
(1, 'MEC-003', 'Edson Ferreira Matos',     'MOTOR',           'Av. Contorno, 77 - Anil',        'São Luís',        'MA', '65045000'),
(2, 'MEC-004', 'Cláudio Roberto Dias',     'SUSPENSAO',       'Rua 3, 120 - Turu',              'São Luís',        'MA', '65066260'),
(2, 'MEC-005', 'Marcos Vinícius Rocha',    'FREIOS',          'Rua 15, 18 - Vinhais',           'São Luís',        'MA', '65074080'),
(2, 'MEC-006', 'Sebastião Gomes Pinto',    'SUSPENSAO',       'Rua São Pantaleão, 500 - Centro','São Luís',        'MA', '65015460'),
(3, 'MEC-007', 'Thiago Henrique Moura',    'ELETRICA',        'Av. Guajajaras, 1010 - Tirirical','São Luís',       'MA', '65055285'),
(3, 'MEC-008', 'Adriana Sousa Lopes',      'AR_CONDICIONADO', 'Rua 20, 65 - Araçagy',           'São José de Ribamar', 'MA', '65110000'),
(3, 'MEC-009', 'Wellington Batista Reis',  'REVISAO_GERAL',   'Rua 4, 210 - Cidade Operária',   'São Luís',        'MA', '65058000');

-- --------------------------------------------------------------------------
-- TABELA DE MÃO DE OBRA E CATÁLOGO DE PEÇAS
-- --------------------------------------------------------------------------
INSERT INTO servico (descricao, valor_mao_de_obra) VALUES
('Troca de óleo e filtro',              80.00),   -- 1
('Revisão preventiva completa',        350.00),   -- 2
('Alinhamento e balanceamento',        120.00),   -- 3
('Troca de pastilhas de freio',        150.00),   -- 4
('Substituição de amortecedores (par)',280.00),   -- 5
('Diagnóstico eletrônico (scanner)',   100.00),   -- 6
('Retífica de motor',                 2500.00),   -- 7
('Troca de embreagem',                 600.00),   -- 8
('Higienização do ar-condicionado',    180.00),   -- 9
('Troca de bateria',                    50.00);   -- 10

INSERT INTO peca (nome_peca, valor_unitario) VALUES
('Óleo de motor 5W30 (litro)',          45.00),   -- 1
('Filtro de óleo',                      35.00),   -- 2
('Filtro de ar',                        55.00),   -- 3
('Pastilha de freio dianteira (jogo)', 180.00),   -- 4
('Disco de freio (par)',               420.00),   -- 5
('Amortecedor dianteiro',              390.00),   -- 6
('Kit de embreagem',                   950.00),   -- 7
('Bateria 60Ah',                       520.00),   -- 8
('Vela de ignição',                     38.00),   -- 9
('Correia dentada',                    160.00),   -- 10
('Jogo de juntas do motor',            680.00),   -- 11
('Filtro de cabine',                    48.00);   -- 12 (nunca utilizada)

-- --------------------------------------------------------------------------
-- ORDENS DE SERVIÇO
-- O veículo 1 (Strada) passou por equipes diferentes em visitas diferentes:
-- é isso que justifica a equipe ficar na OS, e não no veículo.
-- OS 2 e 5 foram concluídas com atraso; a OS 11 está atrasada em aberto.
-- --------------------------------------------------------------------------
INSERT INTO ordem_servico (numero_os, id_veiculo, id_equipe, tipo_os, status_os, data_emissao, data_prevista_conclusao, data_conclusao, autorizado_pelo_cliente, data_autorizacao, observacao) VALUES
('OS-2026-0001', 1,  3, 'REVISAO',  'CONCLUIDA',              '2026-08-04', '2026-08-05', '2026-08-05', TRUE,  '2026-08-04 09:30', 'Revisão dos 40.000 km'),               -- 1
('OS-2026-0002', 4,  1, 'CONSERTO', 'CONCLUIDA',              '2026-08-12', '2026-08-22', '2026-08-26', TRUE,  '2026-08-12 15:00', 'Motor fundido, aguardou juntas'),     -- 2
('OS-2026-0003', 7,  2, 'CONSERTO', 'CONCLUIDA',              '2026-08-20', '2026-08-23', '2026-08-22', TRUE,  '2026-08-20 10:10', 'Freios dos dois eixos'),              -- 3
('OS-2026-0004', 3,  3, 'REVISAO',  'CONCLUIDA',              '2026-09-02', '2026-09-02', '2026-09-02', TRUE,  '2026-09-02 08:45', 'Revisão anual'),                      -- 4
('OS-2026-0005', 8,  1, 'CONSERTO', 'CONCLUIDA',              '2026-09-10', '2026-09-14', '2026-09-16', TRUE,  '2026-09-10 11:20', 'Embreagem patinando'),                -- 5
('OS-2026-0006', 1,  2, 'CONSERTO', 'CONCLUIDA',              '2026-09-18', '2026-09-19', '2026-09-19', TRUE,  '2026-09-18 09:00', 'Barulho na suspensão dianteira'),     -- 6
('OS-2026-0007', 10, 3, 'CONSERTO', 'CONCLUIDA',              '2026-09-25', '2026-09-25', '2026-09-25', TRUE,  '2026-09-25 08:15', 'Veículo não dava partida'),           -- 7
('OS-2026-0008', 9,  2, 'CONSERTO', 'CONCLUIDA',              '2026-10-06', '2026-10-09', '2026-10-09', TRUE,  '2026-10-06 14:00', 'Amortecedores vazando'),              -- 8
('OS-2026-0009', 2,  1, 'CONSERTO', 'CANCELADA',              '2026-10-14', '2026-10-20', NULL,         FALSE, NULL,               'Cliente recusou o orçamento'),        -- 9
('OS-2026-0010', 11, 3, 'REVISAO',  'CONCLUIDA',              '2026-10-21', '2026-10-21', '2026-10-22', TRUE,  '2026-10-21 10:30', 'Revisão da frota'),                   -- 10
('OS-2026-0011', 7,  3, 'REVISAO',  'EM_EXECUCAO',            '2026-11-03', '2026-11-06', NULL,         TRUE,  '2026-11-03 16:20', 'Revisão preventiva da frota'),        -- 11
('OS-2026-0012', 5,  2, 'CONSERTO', 'EM_EXECUCAO',            '2026-11-05', '2026-11-09', NULL,         TRUE,  '2026-11-05 13:05', 'Freio rangendo'),                     -- 12
('OS-2026-0013', 1,  3, 'REVISAO',  'AGUARDANDO_AUTORIZACAO', '2026-11-06', '2026-11-07', NULL,         FALSE, NULL,               'Revisão dos 50.000 km'),              -- 13
('OS-2026-0014', 4,  2, 'CONSERTO', 'EM_AVALIACAO',           '2026-11-07', '2026-11-12', NULL,         FALSE, NULL,               'Vibração ao frear');                  -- 14

-- --------------------------------------------------------------------------
-- SERVIÇOS DE CADA OS (preço praticado)
-- Clientes PJ com frota recebem desconto na mão de obra.
-- A OS 14 ainda está em avaliação e não tem itens.
-- --------------------------------------------------------------------------
INSERT INTO os_servico (id_os, id_servico, quantidade, valor_unitario) VALUES
(1,  2, 1,  350.00), (1,  1, 1,   80.00),
(2,  7, 1, 2500.00), (2,  6, 1,  100.00),
(3,  4, 2,  135.00), (3,  3, 1,  108.00),
(4,  1, 1,   80.00), (4,  9, 1,  180.00),
(5,  8, 1,  540.00),
(6,  5, 1,  280.00), (6,  3, 1,  120.00),
(7,  6, 1,  100.00), (7, 10, 1,   50.00),
(8,  5, 2,  252.00),
(9,  8, 1,  600.00),
(10, 2, 1,  350.00), (10, 9, 1,  180.00),
(11, 2, 1,  315.00), (11, 1, 1,   72.00),
(12, 4, 1,  150.00), (12, 3, 1,  120.00),
(13, 2, 1,  350.00);

-- --------------------------------------------------------------------------
-- PEÇAS DE CADA OS (preço praticado)
-- --------------------------------------------------------------------------
INSERT INTO os_peca (id_os, id_peca, quantidade, valor_unitario) VALUES
(1,  1, 4,  45.00), (1,  2, 1,  35.00), (1, 3, 1, 55.00), (1, 9, 4, 38.00),
(2, 11, 1, 680.00), (2, 10, 1, 160.00), (2, 1, 4, 45.00),
(3,  4, 2, 170.00), (3,  5, 2, 400.00),
(4,  1, 4,  45.00), (4,  2, 1,  35.00),
(5,  7, 1, 900.00),
(6,  6, 2, 390.00),
(7,  8, 1, 520.00),
(8,  6, 4, 360.00),
(9,  7, 1, 950.00),
(10, 1, 6,  45.00), (10, 2, 1,  35.00), (10, 3, 1, 55.00),
(11, 1, 8,  42.00), (11, 2, 1,  32.00),
(12, 4, 1, 180.00),
(13, 1, 4,  45.00), (13, 2, 1,  35.00);
