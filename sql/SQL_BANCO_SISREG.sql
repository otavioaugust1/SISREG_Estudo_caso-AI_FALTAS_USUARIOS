
SELECT

RIGHT(REVERSE(
	REPLACE(SOL.nu_cns_paciente,'0','X')),11) 	AS "CNS_USUARIO",		-- CNS ANONIMIZADO
--SOL.nu_cns_paciente 							AS "CNS_USUARIO",   	-- CNS USUARIO
--USU.no_usuario								AS "NOME_USUARIO",		-- NOME USUARIO
((SOL.dt_solicitacao - USU.dt_nascimento)/365)	AS "IDADE_USUARIO",   	-- IDADE DO PACIENTE NO ATO DA SOLICITAÇÃO 
PDR.no_municipio 								AS "MUNICIPIO_USUARIO", -- CONFORME CADWEB
USU.co_municipio_ibge							AS "IBGE_USUARIO",		-- CONFORME CADWEB

(CASE
	WHEN USU.co_sexo = 'F' THEN 'FEMININO' 
	WHEN USU.co_sexo = 'M' THEN 'MASCULINO'
	ELSE 'INDEFINIDO/NÃO INFORMADO' END)		AS "SEXO_USUARIO",		-- CONFORME CADWEB 
	
(CASE 
	WHEN USU.tp_raca = '01' THEN 'Branca'
	WHEN USU.tp_raca = '02' THEN 'Negra'
	WHEN USU.tp_raca = '03' THEN 'Amarela'
	WHEN USU.tp_raca = '04' THEN 'Parda'
	WHEN USU.tp_raca = '05' THEN 'Indigena'
	ELSE 'Indefinida' END) 						AS "RACA_COR_USUARIO", 	-- CONFORME IBGE 
					
USU.nu_cep										AS "CEP_USUARIO",		-- CONFORME CADWEB 

(CASE
	WHEN USU.co_municipio_ibge = USU.co_municipio_ibge 
 		THEN 'ATENDIDO NO MESMO MUNICIPIO DE RESIDENCIA DO USUARIO'
 	WHEN SUBSTRING(USU.co_municipio_ibge, 1,2) = SUBSTRING(USU.co_municipio_ibge, 1,2) 
 		THEN 'ATENDIDO EM OUTRO MUNICIPIO DENTRO DO ESTADO DO USUARIO'
 	ELSE 'ATENDIDO FORA DO ESTADO DO USUARIO' END) AS "DESLOCAMENTO",	-- RELAÇÃO ESTUDO ANTERIOR
MAR.co_cnes_ups									AS "CNES_EXECUTANTE",	-- CONFORME SISREG
UPS.nu_cep										AS "CEP_UNID_EXECUTANTE",
CBO.co_cbo 										AS "ESPECIALIDADE",		-- CONFORME SISREG

(CASE 
 	WHEN SOL.nu_carater = '0' 
 		THEN 'Prioridade Zero - Emergência, necessidade de atendimento imediato'
 	WHEN SOL.nu_carater = '1' 
 		THEN 'Prioridade 1 - Urgência, atendimento o mais rápido possível' 
	WHEN SOL.nu_carater = '2' 
  		THEN 'Prioridade 2 - Prioridade não urgente'
	ELSE 'Prioridade 3 - atendimento eletivo ' END) AS "GRAVIDADE",		-- CONFORME SISREG
 									
MAR.dt_marcacao 								AS "DATA_ATEND",
(mar.dt_marcacao - SOL.dt_solicitacao) 			AS "TEMPO_ESPERA",		-- TEMPO EM DIAS
(CASE
	WHEN MAR.st_falta = '0' THEN 'CONF'
	WHEN MAR.st_falta = '1' THEN 'FALTA'
	ELSE 'PEND' END)							AS "CONF_ATEND",
COUNT(1) AS QUANT

FROM	dbregulacao.tb_solicitacao 		AS SOL
JOIN	dbregulacao.tb_marcacao 		AS MAR ON (sol.co_seq_solicitacao = mar.co_solicitacao)
JOIN	dbregulacao.tb_usuario 			AS USU ON (SOL.nu_cns_paciente = USU.nu_cns_paciente)
JOIN 	dbregulacao.rl_procedimento_cbo	AS CBO ON (SOL.co_pa_interno = CBO.co_pa_interno)
JOIN 	dbregulacao.tb_pdr 				AS PDR ON (USU.co_municipio_ibge = PDR.co_municipio_ibge)
JOIN	dbregulacao.tb_ups				AS UPS ON (MAR.co_cnes_ups = UPS.co_cnes_ups)

WHERE 	mar.dt_marcacao BETWEEN '2020-05-01' AND '2020-05-01' 
AND 	MAR.st_falta >= '0' 				-- APENAS SOLICITAÇÕES CONFIRMADAS OU COM FALTAS
AND		SOL.st_situacao in ('A')			-- APENAS SOLICITAÇÕES AGENDADAS
AND 	LENGTH(USU.nu_cep) = 8  			-- TRAZER APENAS PACIENTES COM CEP 
AND 	CBO.co_procedimento like '030101%'	-- CONSULTA MEDICAS GERAL (ATENÇÃO BASICA E ESPECIALIZADA)

GROUP BY 	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15


