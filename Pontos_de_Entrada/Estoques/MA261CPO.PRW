/*
PONTO.......: MA261CPO          PROGRAMA....: MATA261
DESCRIÇÄO...: ADICIONA CAMPOS NO AHEADER
UTILIZAÇÄO..: E chamado logo apos a criacao do array aHeader que
              controla quais campos aparecerao no browse das transferencias.
              Pode ser utilizado para inclusao de campos no array ja mencionado,
              permitindo ao usuario incluir mais campos para digitacao.

O array aHeader e montado baseado em campos do arquivo SD3.

PARAMETROS..: UPAR do tipo X :

RETORNO.....: URET do tipo X :
*/
#DEFINE USADO Chr(0)+Chr(0)+Chr(1)

User Function ma261cpo()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
aTam := TamSX3('D3_EXPLIC')
Aadd(aHeader, {'Explicação','D3_EXPLIC', PesqPict('SD3','D3_EXPLIC',aTam[1]),aTam[1],aTam[2],'', USADO, 'C', 'SD3', ''})

// Cria somente como visualizacao, pois somente sera preenchido pela rotina automatica disparada na separacao.
aTam := TamSX3('D3_NUMSEP')
Aadd(aHeader, {'N.Separacao','D3_NUMSEP', PesqPict('SD3','D3_NUMSEP',aTam[1]),aTam[1],aTam[2],'', USADO, 'C', 'SD3','' , , , , "V", , , })
Return