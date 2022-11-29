
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
	WHEN USU.tp_raca = '01' THEN 'BRANCA'
	WHEN USU.tp_raca = '02' THEN 'PRETA'
	WHEN USU.tp_raca = '03' THEN 'AMARELA'
	WHEN USU.tp_raca = '04' THEN 'PARDA'
	WHEN USU.tp_raca = '05' THEN 'INDIGENA'
	ELSE 'INDEFENIDA' END) 						AS "RACA_COR_USUARIO", 	-- CONFORME IBGE 
					
USU.nu_cep										AS "CEP_USUARIO",		-- CONFORME CADWEB 

(CASE
	WHEN USU.co_municipio_ibge = USU.co_municipio_ibge 
 		THEN 'ATENDIDO NO MESMO MUNICIPIO DE RESIDENCIA DO USUARIO'
 	WHEN SUBSTRING(USU.co_municipio_ibge, 1,2) = SUBSTRING(USU.co_municipio_ibge, 1,2) 
 		THEN 'ATENDIDO EM OUTRO MUNICIPIO DENTRO DO ESTADO DO USUARIO'
 	ELSE 'ATENDIDO FORA DO ESTADO DO USUARIO' END) AS "DESLOCAMENTO",	-- RELAÇÃO ESTUDO ANTERIOR
	
MAR.co_cnes_ups									AS "CNES_EXECUTANTE",	-- CONFORME SISREG
UPS.nu_cep										AS "CEP_UNID_EXECUTANTE",  --CONFORME CNES
UPPER(ESP.ds_cbo_ocupacao)						AS "ESPECIALIDADE",		-- CONFORME SISREG

(CASE 
 	WHEN SOL.nu_carater = '0' 
 		THEN 'PRIORIDADE ZERO - EMERGÊNCIA, NECESSIDADE DE ATENDIMENTO IMEDIATO'
 	WHEN SOL.nu_carater = '1' 
 		THEN 'PRIORIDADE 1 - URGÊNCIA, ATENDIMENTO O MAIS RÁPIDO POSSÍVEL' 
	WHEN SOL.nu_carater = '2' 
  		THEN 'PRIORIDADE 2 - PRIORIDADE NÃO URGENTE'
	ELSE 'PRIORIDADE 3 - ATENDIMENTO ELETIVO' END) AS "GRAVIDADE",		-- CONFORME SISREG
 									
DATE(MAR.dt_marcacao) 							AS "DATA_ATEND",
(mar.dt_marcacao - SOL.dt_solicitacao) 			AS "TEMPO_ESPERA",		-- TEMPO EM DIAS
(CASE
 	WHEN MAR.st_falta = '1' THEN 'FALTA'
 	WHEN MAR.st_falta = '0' AND	MAR.st_marcacao_executada = 'S'	 THEN 'CONFIRMADO'
	ELSE 'PENDENTE' END)						AS "CONF_ATEND", 		-- 
COUNT(1) AS QUANT

FROM	dbregulacao.tb_solicitacao 		AS SOL
JOIN	dbregulacao.tb_marcacao 		AS MAR ON (sol.co_seq_solicitacao = mar.co_solicitacao)
JOIN	dbregulacao.tb_usuario 			AS USU ON (SOL.nu_cns_paciente = USU.nu_cns_paciente)
JOIN 	dbregulacao.rl_procedimento_cbo	AS CBO ON (SOL.co_pa_interno = CBO.co_pa_interno)
JOIN 	dbregulacao.tb_pdr 				AS PDR ON (USU.co_municipio_ibge = PDR.co_municipio_ibge)
JOIN	dbregulacao.tb_ups				AS UPS ON (MAR.co_cnes_ups = UPS.co_cnes_ups)
JOIN	dbgeral.tb_cbo_ocupacao			AS ESP ON (CBO.co_cbo = ESP.co_cbo_ocupacao)	


WHERE 	
		mar.dt_marcacao BETWEEN '2020-04-01' AND '2022-03-31' -- PROJETO
	--	mar.dt_marcacao BETWEEN '2020-05-01' AND '2020-05-01' -- DATA USADA PARA O TESTE
AND 	MAR.st_falta >= '0' 				-- APENAS SOLICITAÇÕES CONFIRMADAS OU COM FALTAS
AND		SOL.st_situacao in ('A')			-- APENAS SOLICITAÇÕES AGENDADAS
AND 	LENGTH(USU.nu_cep) = 8  			-- TRAZER APENAS PACIENTES COM CEP 
AND 	CBO.co_procedimento = '0301010072'	-- CONSULTA MEDICAS ESPECIALIZADA
AND		(CASE
 	WHEN MAR.st_falta = '1' THEN 'FALTA'
 	WHEN MAR.st_falta = '0' AND	MAR.st_marcacao_executada = 'S'	 THEN 'CONFIRMADO'
	ELSE 'PENDENTE' END) IN ('CONFIRMADO','FALTA') -- TRAZER APENAS OS CONFIRMADOS E FALTAS

GROUP BY 	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
