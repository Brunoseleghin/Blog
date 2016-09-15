#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <windows.h>
#include <gdiplus.h>
#include <memory>

#include "GetScreen.hpp"

/* ------------------------------------------------------------
Programa  GetScreen
Autor     J�lio Wittwer
Data      07/09/2016
Descri��o DLL Win32 para uso com o TOTVS SmartClient
          Permite a captura da tela do computador onde o SmartClient est� sendo executado
          gerada como uma imagem .JPEG salva em disco, usando o nome do arquivo fornecido 
          como par�metro.

Utiliza��o 

          Utilizar a fun��o ExecInClientDLL(), informando os seguintes par�metros: 

          int ID => N�mero da opera��o desejada 
                    0 = Obter a vers�o da API 
                    1 = Capturar um ScreenShot em formato JPEG

          char * BufIn => array de char contendo um par�metro para a op��o.
          SE ID = 0, o par�metro � ignorado e pode ser NULL
          SE ID = 1, deve ser informado o nome do arquivo JPEG no qual a 
          captura de tela deve ser gravada. 

          char * BufOut => Array de char contendo o resultado da chamada, no formato 
          NNN XXXXXXXX, onde NNN � um C�digo de Status , e XXXXX cont�m uma informa��o 
          adicional sobre o status retornado. Em caso de sucesso, o n�mero retornado � "000"
          Qualquer outro n�mero indica uma condi��o de falha. 

          "001 Encode size failed"
          "002 Memory allocation failed"
          "003 Image Codec not found"
          "004 Image Save Error (%d)"
          "005 Unexpected Error %d
          "010 Unknow Command"

------------------------------------------------------------ */


extern "C" __declspec(dllexport) void ExecInClientDLL( int ID, char * BufIn, char * BufOut, int nSizeOut )
{

  if( ID == 0 )
  {
    // Retorna a vers�o da DLL de captura
    strcpy(BufOut,"000 GetScreen V 0.160911");
  }
  else if (ID == 1)
  {
    // REaliza a captura da tela
    // Recebe em BuffIn o nome do arquivo a ser salvo 
    // Retona em buffOut o status da opera��o 
    // Em caso de sucesso, retorno "000 Ok"
    // Em caso de erro, retorno "NNN <error message>"
    DoCapture(BufIn,BufOut);
  }
  else
  {
    // ID n�o conhecido/inv�lido 
    strcpy(BufOut,"010 Unknow Command");
  }
}


/* ------------------------------------------------------------
Codigo exemplo de captura de tela obtido HitHub
https://gist.github.com/philipgoh/3865787
em 07/9/2016, refatorado para atender a necessidade 
deste exemplo
------------------------------------------------------------ */


using namespace Gdiplus;
using namespace std;

// Inicializa GDI para a captura de v�deo
// faz a captura, salva em disco, e finaliza GDI

void DoCapture(  char * file , char * result ) 
{

  // Initialize GDI+.
  GdiplusStartupInput gdiplusStartupInput;
  ULONG_PTR gdiplusToken;

  GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);

  int x1 = 0;
  int y1 = 0;
  int x2 = GetSystemMetrics(SM_CXSCREEN);
  int y2 = GetSystemMetrics(SM_CYSCREEN);

  // Realiza a captura da tela e salva em arquivo 
  ScreenCapture(x1, y1, x2 - x1, y2 - y1,  file , result );

  // Shutdown GDI+
  GdiplusShutdown(gdiplusToken);

}


// Retorna o ponteiro do encoder adequado para fazer
// a convers�o do BITMAP em mem�ria para o formato desejado


int GetEncoderClsid(const WCHAR* format, CLSID* pClsid )
{
  UINT num = 0;          // number of image encoders
  UINT size = 0;         // size of the image encoder array in bytes

  ImageCodecInfo* pImageCodecInfo = NULL;

  GetImageEncodersSize(&num, &size);

  if(size == 0)
  {
    // Encode Size Failure
    return -1;  
  }

  pImageCodecInfo = (ImageCodecInfo*)(malloc(size));
  if(pImageCodecInfo == NULL)
  {
    // Memory allocation failure
    return -2;  
  }

  GetImageEncoders(num, size, pImageCodecInfo);

  for(UINT j = 0; j < num; ++j)
  {
    if( wcscmp(pImageCodecInfo[j].MimeType, format) == 0 )
    {
      *pClsid = pImageCodecInfo[j].Clsid;
      free(pImageCodecInfo);
      // Success
      return j;  
    }    
  }

  free(pImageCodecInfo);

  // Image Codec not found
  return -3;  
}

// Encapsula a grava��o do BITMAP capturado da tela
// para o formato JPEG em disco 

void BitmapToJpg(HBITMAP hbmpImage, char *filename , char * result )
{

  Status eRC = Ok;

  Bitmap * p_bmp = Bitmap::FromHBITMAP(hbmpImage, NULL);

  CLSID pngClsid;

  int RC = GetEncoderClsid(L"image/jpeg", &pngClsid);

  if( RC >= 0 )
  {
    const size_t cSize = strlen(filename)+1;
    std::wstring wc( cSize, L'#' );
    mbstowcs( &wc[0], filename, cSize );
    eRC = p_bmp->Save(&wc[0], &pngClsid, NULL);
    if ( eRC != Ok)
      RC = -4;
  }

  delete p_bmp;

  if ( RC == -1 )
    sprintf_s(result,255,"001 Encode size failed");
  else if ( RC == -2 )
    sprintf_s(result,255,"002 Memory allocation failed");
  else if ( RC == -3 )
    sprintf_s(result,255,"003 Image Codec not found");
  else if ( RC == -4 )
    sprintf_s(result,255,"004 Image Save Error (%d)",eRC);
  else if ( RC < 0 )
    sprintf_s(result,255,"005 Unexpected Error %d",RC);
  else
    sprintf_s(result,255,"000 Ok");

}


// Fun�o de captura / snapshot de tela
// Requer o ambiente DGI previamente inicializado

void ScreenCapture(int x, int y, int width, int height, char *filename, char * result )
{
  HDC hDc = CreateCompatibleDC(0);
  HBITMAP hBmp = CreateCompatibleBitmap(GetDC(0), width, height);

  SelectObject(hDc, hBmp);
  BitBlt(hDc, 0, 0, width, height, GetDC(0), x, y, SRCCOPY);

  // Converte a tela capturada em JPEG e salva em disco 
  BitmapToJpg(hBmp, filename , result );

  DeleteObject(hBmp);

}

