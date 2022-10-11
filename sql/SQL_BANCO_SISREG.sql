
SELECT

SOL.nu_cns_paciente 							AS "CNS_USUARIO",
USU.no_usuario									AS "NOME_USUARIO",
((SOL.dt_solicitacao - USU.dt_nascimento)/365)	AS "IDADE_USUARIO",
PDR.no_municipio 								AS "MUNICIPIO_USUARIO",
USU.co_municipio_ibge							AS "IBGE_USUARIO",
USU.co_sexo									  	AS "SEXO_USUARIO",
SUBSTRING(USU.tp_raca,2)						AS "RACA_COR_USUARIO",
USU.nu_cep										AS "CEP_USUARIO",
(CASE
	WHEN USU.co_municipio_ibge = USU.co_municipio_ibge THEN '1'
 	WHEN SUBSTRING(USU.co_municipio_ibge, 1,2) = SUBSTRING(USU.co_municipio_ibge, 1,2) THEN '2'
 	ELSE '3' END) 								AS "DESLOCAMENTO",
MAR.co_cnes_ups									AS "CNES_EXECUTANTE",
CBO.co_cbo 										AS "ESPECIALIDADE",
SOL.nu_carater 									AS "GRAVIDADE",
MAR.dt_marcacao 								AS "DATA_ATEND",
(mar.dt_marcacao - SOL.dt_solicitacao) 			AS "TEMPO_ESPERA",
(CASE
	WHEN MAR.st_falta = '0' THEN 'CONF'
	WHEN MAR.st_falta = '1' THEN 'FALTA'
	ELSE 'PEND' END)							AS "CONF_ATEND"


FROM	dbregulacao.tb_solicitacao 		AS SOL
JOIN	dbregulacao.tb_marcacao 		AS MAR ON (sol.co_seq_solicitacao = mar.co_solicitacao)
JOIN	dbregulacao.tb_usuario 			AS USU ON (SOL.nu_cns_paciente = USU.nu_cns_paciente)
JOIN 	dbregulacao.rl_procedimento_cbo	AS CBO ON (SOL.co_pa_interno = CBO.co_pa_interno)
JOIN 	dbregulacao.tb_pdr 				AS PDR ON (USU.co_municipio_ibge = PDR.co_municipio_ibge)

WHERE 	mar.dt_marcacao BETWEEN '2020-04-01' AND '2022-03-31' 
AND 	MAR.st_falta >= '0' 
AND		SOL.st_situacao in ('A')
AND 	LENGTH(USU.nu_cep) = 8
AND 	CBO.co_procedimento like '030101%'	

GROUP BY 	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15


