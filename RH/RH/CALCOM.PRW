#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CALCOM   � Autor � Jose Carlos Gouveia� Data �  23/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Calculo de Comissao                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE -                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CalCom()

// Declaracao de Variaveis

SetPrvt("nComTot_,nCom_,nDsr_")

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

//Verifica Existencia da Verba
If fBuscaPD("960","V") = 0
	Return
Endif

//Inicia Variaveis
nComTot_	:=	0
nCom_		:= 0
nDsr_		:= 0

//Processamento
//Importa Comissao
nComTot_	:= fBuscaPD("960","V") 

//Calculo da Comissao
nCom_ := (nComTot_/(Normal + Descanso)) * Normal
nDsr_ := nComTot_ - nCom_

// Verifica se Verba Informada
If fBuscaPD(aCodFol[165,1],"V") > 0
	If aPd[fLocaliaPd(aCodfol[165][1]),7] == "I"
        Return
 	Endif
End

//Gera Verba
//Comissao
fGeraVerba((aCodFol[165][1]),nCom_)

//DSR
fGeraVerba((aCodFol[166][1]),nDsr_)

Return

//Fim da Rotina