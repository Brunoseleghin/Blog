#INCLUDE "protheus.ch"

/* ======================================================================
Fun��o      U_APTST2
Autor       J�lio Wittwer
Data        02/12/2014
Descri��o   Fonte de teste e demonstra��o de heran�a
            de classes na orienta��o a objeto do AdvPL 

Post relacionado : https://siga0984.wordpress.com/2014/12/02/classes-em-advpl-parte-02/
====================================================================== */

// Fonte de teste da classe com heran�a
User Function APTST2() 
Local oObj
oObj := APFILHA():New(123)
oObj:SayValue()
Return

// -----------------------------------------------------------
// Classe superior para demonstra��o de heran�a
CLASS APPAI
  DATA nValue as Integer
  METHOD New(nNum) CONSTRUCTOR
  METHOD SayValue()
ENDCLASS

// Construtor da classe pai, recebe um valor e guarda. 
METHOD New(nNum) CLASS APPAI
::nValue := nNum
Return self

// Mostra o valor guardado na tela, identificando na tela que 
// o m�todo da classe Pai foi utilizado 
METHOD SayValue() CLASS APPAI
MsgInfo(::nValue,"Classe Pai")
Return

// -----------------------------------------------------------
// Classe Filha, herda a classe pai 
CLASS APFILHA FROM APPAI
  METHOD NEW(nNum) CONSTRUCTOR
  METHOD SayValue( lPai )
ENDCLASS

// Construtor da filha chama construtor da classe pai
METHOD NEW(nNum) CLASS APFILHA
_Super:New(nNum)
return self

// Metodo para mostrar o valor, pergunta ao operador se 
// deve ser chamado o metodo da classe pai ou n�o. 
METHOD SayValue() CLASS APFILHA
If MsgYesNo("Chamar a classe pai ?")
  _Super:SayValue()
Else
  MsgInfo(::nValue,"Classe Filha")
Endif
Return
