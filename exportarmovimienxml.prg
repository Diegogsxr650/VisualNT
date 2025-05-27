SET DATE TO GERMAN
SET PATH TO "C:\temp\PracticaSanAndres"

LOCAL lcArchivoXML, lnHandle, lcLineaXML
LOCAL aCampos[1]
LOCAL i, lnNumCampos, lcCampo, lcValor

* Verificación de permisos de acceso a la carpeta
lnHandle = FCREATE("C:\temp\PracticaSanAndres\test.txt")
IF lnHandle < 0
    ? "No tengo permisos para escribir en la carpeta"
    RETURN
ELSE
    =FCLOSE(lnHandle)
ENDIF

* Verificar apertura de la tabla
USE C:\temp\PracticaSanAndres\movimien ORDER Documento IN 0 SHARED
IF !USED("movimien")
    ? "No se pudo abrir la tabla movimien"
    RETURN
ELSE
    ? "Tabla movimien abierta correctamente"
ENDIF

* Ruta del fichero XML
lcArchivoXML = "C:\temp\PracticaSanAndres\movimien.xml"
lnHandle = FCREATE(lcArchivoXML)

* Verificación si el archivo se abrió correctamente
IF lnHandle < 0
    ? "Error al abrir el archivo XML para escritura"
    RETURN
ENDIF

* Escribir la cabecera del XML
FWRITE(lnHandle, '<?xml version="1.0" encoding="UTF-8"?>' + CHR(13) + CHR(10))
FWRITE(lnHandle, '<lines>' + CHR(13) + CHR(10))

* Obtener los nombres de los campos
AFIELDS(aCampos)
lnNumCampos = ALEN(aCampos, 1)

* Recorrer cada registro
SCAN
    FWRITE(lnHandle, '  <line>' + CHR(13) + CHR(10))
    
    FOR i = 1 TO lnNumCampos
        lcCampo = aCampos[i, 1]
        lcValor = movimien.&lcCampo  && Acceder directamente al campo

        * Convertir valor a string dependiendo del tipo
        DO CASE
            CASE VARTYPE(lcValor) == "C"
                lcValor = ALLTRIM(lcValor)
            CASE VARTYPE(lcValor) == "N"
                lcValor = TRANSFORM(lcValor)
            CASE VARTYPE(lcValor) == "D"
                lcValor = DTOC(lcValor)
            CASE VARTYPE(lcValor) == "L"
                lcValor = IIF(lcValor, "true", "false")
            OTHERWISE
                lcValor = ""
        ENDCASE

        * Escapar caracteres especiales XML
        lcValor = STRTRAN(lcValor, "&", "&amp;")
        lcValor = STRTRAN(lcValor, "<", "&lt;")
        lcValor = STRTRAN(lcValor, ">", "&gt;")
        lcValor = STRTRAN(lcValor, '"', "&quot;")
        lcValor = STRTRAN(lcValor, "'", "&apos;")

        * Escribir etiqueta XML
        FWRITE(lnHandle, "    <" + lcCampo + ">" + lcValor + "</" + lcCampo + ">" + CHR(13) + CHR(10))
    ENDFOR

    FWRITE(lnHandle, '  </line>' + CHR(13) + CHR(10))
ENDSCAN

* Cerrar XML
FWRITE(lnHandle, '</lines>' + CHR(13) + CHR(10))
=FCLOSE(lnHandle)

* Cerrar tabla
USE IN movimien

? "Exportación completada. El archivo XML se creó correctamente."




