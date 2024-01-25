' Aplicación - Visual Basic: Elaborador de Cartones de Bingo
' Última Edición: 5 de enero de 2024
'
' Este programa permite elaborar cartones de Bingo de forma automática introdujendo los valores de dimensiones y cantidad de los cartones de Bingo, así como también su posterior limpieza
    ' para comenzar con uno nuevo.

Private Sub Limpiar_Click()

MsgBox ("A continuación se realizará la limpieza de la hoja de cálculo. Esto puede tomar unos poquitos minutos.")

    For Cleani = 1 To 70
        For Cleanj = 1 To 70
            
            If Cells(Cleani, Cleanj) <> " " Then
                Cells(Cleani, Cleanj) = " "
            End If
            
            If Cells(Cleani, Cleanj).Interior.ColorIndex <> 0 Then
                Cells(Cleani, Cleanj).Interior.ColorIndex = 0
            End If
            
            If Cells(Cleani, Cleanj).HorizontalAlignment = xlCenter Then
                Cells(Cleani, Cleanj).HorizontalAlignment = xlCenter
            End If
            
            If Cells(Cleani, Cleanj).VerticalAlignment = xlCenter Then
                Cells(Cleani, Cleanj).VerticalAlignment = xlCenter
            End If
            
            Rows("1:100").RowHeight = 40
            Columns("A:BZ").ColumnWidth = 11
            
        Next Cleanj
    Next Cleani

    'Range("A1:BZ100").Merge
    Range("A1:BZ100").UnMerge
    
End Sub

Private Sub MensajeInicial_Click()

MsgBox ("Hola. Este programa te permite elaborar un tablero y la cantidad que quieras de cartones de bingo.")
MsgBox ("Debes ingresar el rango de valores que quieres para tu bingo, las dimensiones de los cartones, sus letras y la cantidad de cartones que quieras.")
MsgBox ("Se sugiere que cada columna de tablero tenga una longitud mayor a 5 que las filas de cartón (Ej: Si un rango de columna está en 1-15, que el cartón tenga máximo 10 filas), que la cantidad de columnas de cartón sea mayor o igual a 3 y que el nombre contenga diferentes letras.")
MsgBox ("Utiliza el botón 'Crear Cartones' para elaborar tu tablero y tus cartones de Bingo y 'Limpiar' para borrar todo.")

End Sub

Private Sub CrearCartones_Click()

' INTRODUCCIÓN: Se crearán los cartones y un respectivo tablero, estableciendo un espaciado entre ellos. Se utilizará el formato Cell(i, j) / Cell(K, L) / Cell(T, U) / Cell(Fila, Columna)

' PEDIR INFORMACIÓN INICIAL:
    Dim xi As Integer ' Límite Inferior del Rango (Estándar: 1)
    Dim xf As Integer ' Límite Superior del Rango (Estándar: 75)
    Dim n As Integer ' Número de Columnas del Cartón (Estándar: 5)
    Dim m As Integer ' Número de Filas del Cartón (Estándar: 5)
    Dim C As Integer ' Número de Cartones requeridos
    Dim Nombre As String ' Nombre del Bingo (En letras separadas para ser ubicadas en el tablero y los cartones
    Dim VNombre() As String ' Vector para nombre del Bingo, después de haber sido descompuesto en sus partes.
    
    xi = InputBox("Ingresa el Límite Inferior del Rango de Números (Estándar: 1): ")
    xf = InputBox("Ingresa el Límite Superior del Rango de Números (Estándar: 75): ")
    n = InputBox("Ingresa el Número de Columnas del Cartón (Estándar: 5): ")
    m = InputBox("Ingresa el Número de Filas del Cartón (Estándar: 5): ")
    C = InputBox("Ingresa el Número de Cartones Requeridos: ")
    Nombre = InputBox("Ingresa por carácteres separados por un espacio el nombre de tu bingo: ")
    VNombre = Split(Nombre, " ") ' Descomposición del nombre en un vector de elementos, retirando como carácter entre elementos el espacio (" ")
    MsgBox ("A continuación se realizará la elaboración del tablero y los cartones de Bingo. Esto puede tomar unos poquitos minutos dependiendo del tamaño y la cantidad de cartones que pediste.")
    
' CONSTRUIR TABLERO:
    Dim iin As Integer ' Espacio libre inicial horizontal
    Dim jin As Integer ' Espacio libre inicial vertical
    Dim Rango As Integer ' Rango promedio de cada columna. Incrementará o disminuirá dependiendo de la división entre el rango total (xf - xi) y el número de columnas
    Dim U As Integer ' Auxiliar de Columnas para Tablero
    Dim T As Integer ' Auxiliar de Filas para Tablero
    Dim V As Integer ' Auxiliar de contabilización de Columna para valores y colores en el tablero
    Dim p As Integer ' Auxiliar de contabilización de Columna para introducir las letras en el tablero y los cartones
    Dim r As Integer ' Variable de conteo para asignar valores en el tablero
    Dim Col As Integer ' Indicador de coloreado de tablero (1: Ya coloreado totalmente, 0: No coloreado totalmente)
    Dim MaxFila As Integer ' Número de filas máximas que estará teniendo el tablero. Se usa como una referencia para la creación de cartones

    iin = 5: jin = 1  ' Espaciado inicial, de 1 coordenada horizontal / columna y 5 coordenadas verticales / filas
    Rango = (xf - xi + 1) / n ' Determinación del rango para las columnas
    
    ' Ubicación de valores en el tablero
    r = xi - 1: T = 1: U = 1: V = 1: MaxFila = 0 ' Condiciones iniciales para empezar a trabajar
    Do
        r = r + 1 ' Aumentar dígito
        Cells(T + iin + 2, U + jin) = r ' Ubicar dígito en la celda
        T = T + 1 ' Continuar bajando en fila
        
        If MaxFila < T Then
            MaxFila = T - 1 ' Indicador de fila máxima
        End If
        
        If (r = Rango * V + (xi - 1)) And (V < n) Then ' "Si el dígito es igual al rango en la v-columna y v aún es menor que el número de columnas
            ' (Ej: Rangos de 1-15, 16-30 y 31-47 para n = 3. Si r = 30 y v = 2, continuar a columna v = 3. Si r = 45 y v = 3, acabar en esa última columna.
            U = U + 1
            T = 1
            V = V + 1
        End If
    Loop While (r < xf)

    ' Coloreado y decoración de las celdas:
    T = 0: U = 1: V = 1: Col = 0 ' Condiciones iniciales para empezar a trabajar
    Do
        T = T + 1 ' Continuar bajando en fila:
        
        If Int(U / 2) * 2 <> U Then ' Diseño para columnas impares.
            Cells(iin + 1 + T, U + jin).Interior.Color = RGB(248, 124, 207): Cells(iin + 1 + T, U + jin).Font.Bold = False ' Color : Negrita
            Cells(iin + 1 + T, U + jin).Font.Name = "Baguet Script": Cells(iiin + 1 + T, U + jin).Font.Size = 25 ' Fuente : Tamaño
        Else
            If Int(U / 2) * 2 = U Then ' Diseño para columnas pares.
                Cells(iin + 1 + T, U + jin).Interior.Color = RGB(123, 154, 253): Cells(iin + 1 + T, U + jin).Font.Bold = False ' Color : Negrita
                Cells(iin + 1 + T, U + jin).Font.Name = "Baguet Script": Cells(iin + 1 + T, U + jin).Font.Size = 25 ' Fuente : Tamaño
            End If
        End If
        
        ' El ciclo continua descendiendo por cada columna hasta que se llega al valor de la máxima fila sobre la que se puso un número. Se colorea una fila más y luego se dirige a la
            ' siguiente columna:
        If (T = MaxFila + 2) And (V < n) Then
            U = U + 1
            T = 0
            V = V + 1
        Else
            ' El ciclo se detiene cuando ya se colorean todas las columnas:
            If (T = MaxFila + 2) And (V = n) Then
                Col = 1
            End If
        End If
    Loop While (Col <> 1)
    
    ' Poner Letras al cartón:
    For p = 1 To n Step 1 ' Tomar puesto de la columna / Selección de Fila
        ' Asignar letra y diseño en el tablero:
        Cells(iin + 2, p + jin) = VNombre(p - 1): Cells(iin + 2, p + jin).Font.Bold = True ' Letra : Negrita
        Cells(iin + 2, p + jin).Font.Name = "Baguet Script": Cells(iin + 2, p + jin).Font.Size = 25 ' Fuente : Tamaño
    Next p
        
    ' Poner título y diseño al tablero:
    Range(Cells(iin + 1, jin + 1), Cells(iin + 1, jin + n)).Merge ' Combinación de todas las celdas superiores:
    Cells(iin + 1, jin + 1) = "Tablero"
    Cells(iin + 1, jin + 1).Interior.Color = RGB(251, 221, 109): Cells(iin + 1, jin + 1).Font.Bold = True ' Color : Negrita
    Cells(iin + 1, jin + 1).Font.Name = "Script MT Bold": Cells(iin + 1, jin + 1).Font.Size = 35 ' Fuente : Tamaño

' CONSTRUIR CARTONES:
    Dim L As Integer ' Auxiliar de Columnas para cartones
    Dim K As Integer ' Auxiliar de Filas para cartones
    Dim D As Integer ' Auxiliar de contador de cartones
    Dim aj As Integer ' Auxiliar de Ubicación de Cartones de forma horizontal.
    Dim ai As Integer ' Auxiliar de Ubicación de Cartones de forma vertical.
    Dim i1 As Integer ' Espacio libre horizontal para poner cartones
    Dim j1 As Integer ' Espacio libre vertical para poner cartones

    aj = 1: ai = 0: i1 = iin: j1 = jin + n + 1: ' Condiciones iniciales para empezar a trabajar
    
    ' Personalización de cartones:
    For D = 1 To C Step 1 ' Selección de Cartón
    
        ' Coloreado de cartones:
        For L = 1 To n Step 1 ' Tomar Fila
            For K = 1 To m + 2 Step 1 ' Tomar puesto de la columna / Selección de Fila
                If Int(L / 2) * 2 <> L Then ' Diseño para columnas impares.
                    Cells(i1 + K, L + j1).Interior.Color = RGB(252, 196, 233): Cells(i1 + K, L + j1).Font.Bold = True ' Color : Negrita
                    Cells(i1 + K, L + j1).Font.Name = "Daytona": Cells(i1 + K, L + j1).Font.Size = 25 ' Fuente : Tamaño
                Else
                    If Int(L / 2) * 2 = L Then ' Diseño para columnas pares.
                        Cells(i1 + K, L + j1).Interior.Color = RGB(168, 188, 254): Cells(i1 + K, L + j1).Font.Bold = False ' Color : Negrita
                        Cells(i1 + K, L + j1).Font.Name = "Daytona": Cells(i1 + K, L + j1).Font.Size = 25 ' Fuente : Tamaño
                    End If
                End If
            Next K ' Seguir con los demás puestos de la columna
        Next L ' Seguir con la siguiente columna:
        
        ' Poner Letra al cartón:
        For p = 1 To n Step 1 ' Tomar puesto de la columna / Selección de Fila
            Cells(i1 + 2, p + j1) = VNombre(p - 1): Cells(i1 + 2, p + j1).Font.Bold = False ' Letra : Negrita
            Cells(i1 + 2, p + j1).Font.Name = "Baguet Script": Cells(i1 + 2, p + j1).Font.Size = 25 ' Fuente : Tamaño
        Next p ' Siga con los demás puestos de la columna
        
        ' Poner Identificación de Cartón:
        Cells(i1 + 1, 1 + j1) = "Carton: "
        Range(Cells(i1 + 1, 1 + j1), Cells(i1 + 1, 2 + j1)).Merge Across:=True ' Unificar las dos celdas horizontales para la palabra Cartón
        Cells(i1 + 1, 3 + j1) = D ' Agregar número de cartón:
        Cells(i1 + 1, 1 + j1).Font.Bold = False: Cells(i1 + 1, 3 + j1).Font.Bold = True ' Negrita para identificación
        Cells(i1 + 1, 1 + j1).Font.Name = "Abadi": Cells(i1 + 1, 3 + j1).Font.Name = "Abadi" ' Fuente para identificación
        Cells(i1 + 1, 1 + j1).Font.Size = 25: Cells(i1 + 1, 3 + j1).Font.Size = 25 ' Tamaño para identificación
        Cells(i1 + 1, 1 + j1).Interior.Color = RGB(255, 255, 255): Cells(i1 + 1, 3 + j1).Interior.Color = RGB(255, 255, 255) ' Color para identificación
        
        ' Al finalizar de personalizar un cartón, seguir con el siguiente cartón a la derecha O revisar si mejor ya toca bajar (Fijado en máximo 5 cartones por fila):
        aj = aj + 1
        j1 = jin + (n + 1) * aj
        If aj = 6 Then
            aj = 1
            ai = ai + 1
            i1 = ai * (m + 3) + iin
            j1 = jin + n + 1
        End If
        
    Next D

' LLENAR CARTONES:
    Dim s(1000) As Variant ' Vector para recoger los valores de una columna de tablero e irlos entregando a la columna del respectivo cartón, a modo de retirar las balotas de una bolsa
    Dim Verif As Integer ' Indicador de que ya se finalizó la selección de valor sobre un puesto
    Dim Oport As Integer ' Cantidad de intentos a realizar para ubicar un número en cada puesto
    
    aj = 1: ai = 0: i1 = iin: j1 = jin + n + 1 ' Condiciones iniciales para empezar a trabajar
    
    For D = 1 To C Step 1 ' Selección de Cartón
        For L = 1 To n Step 1 ' Selección de Columna
    
        ' La adición de un valor sobre un puesto para cada columna consiste en elegir uno de los posibles valores permitidos de la "bolsa" (Vector s) y al tomarlo dejar un 0. Si el valor
            ' tomado resulta ser 0, entonces tiene una cantidad de oportunidades (Fijado en 999) de repetir el intento hasta que lo logre-
            
        ' Elaboración de bolsa / vector: Se emplean los valores del tablero recolectando los de cada columna
        For p = 1 + 2 To MaxFila + 5 Step 1 ' Tener cuidado tanto de no coger las letras (Corrección de 2 puestos adicionales) como de coger todos los valores (Aseguramiento de 5
            ' puestos adicionales)
            s(p) = Cells(iin + p, L + jin)
        Next p
        
        For K = 1 To m Step 1 ' Tomar puesto de la columna / Selección de Fila
            Verif = 0 ' Puesto aún no verificado
            Oport = 0 ' Intentos reiniciados para la selección de cada número
            
            Do
                Pos = Int(Rnd * (MaxFila + 5)) ' Elegir de forma aleatoria un puesto (Valor entero) para tomar su valor en el vector s
                Oport = Oport + 1 ' Intento gastado
            
                If s(Pos) <> 0 Then ' Si la posición no es 0, el valor es apropiado y por eso se puede tomar
                    Cells(i1 + K + 2, L + j1) = s(Pos)
                    Verif = 1
                    s(Pos) = 0
                Else
                    Verif = 0
                End If
                
                If Oport > 999 Then ' Si ya lo intenta 999 veces y aún no se consigue un buen valor, mejor dejar así y finalizar.
                    Verif = 1
                End If
        
            Loop While (Verif = 0)
                
            Next K ' Seguir con los demás puestos de la columna
        Next L ' Seguir con la siguiente columna
        
        ' Al finalizar de llenar un cartón, seguir con el siguiente cartón a la derecha O revisar si mejor ya toca bajar (Fijado en máximo 5 cartones por fila. Todo está acorde a los tableros
            ' ya construidos anteriormente):
        aj = aj + 1
        j1 = jin + (n + 1) * aj
        
        If aj = 6 Then
            aj = 1
            ai = ai + 1
            i1 = ai * (m + 3) + iin
            j1 = jin + n + 1
        End If
    Next D
    
End Sub

Private Sub TestRandom_Click()

For i = 1 To 100
    Cells(2 + i, 2) = Rnd
Next i

End Sub
