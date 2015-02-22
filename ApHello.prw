#include 'protheus.ch'

/* ======================================================================
Fun��o      U_APTST
Autor       J�lio Wittwer
Data        01/12/2014
Descri��o   Fonte de teste e demonstra��o de aplica��o Hello World
            utilizando a orienta��o a objeto no AdvPL 

Post relacionado : https://siga0984.wordpress.com/2014/12/01/classes-em-advpl-parte-01/
====================================================================== */

USER FUNCTION APTST()
Local oObj := APHello():New('Ol� mundo Advpl')
oObj:SayHello()
Return

CLASS APHELLO
  Data cMsg as String
  Method New(cMsg) CONSTRUCTOR
  Method SayHello()
ENDCLASS

METHOD NEW(cMsg) CLASS APHELLO
self:cMsg := cMsg
Return self

METHOD SAYHELLO() CLASS APHELLO
MsgInfo(self:cMsg)
Return .T.

