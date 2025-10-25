import tkinter as tk
from tkinter import ttk, scrolledtext, filedialog, messagebox
import subprocess
import json
import os
import tempfile

class AnalizadorLexicoGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Analizador Léxico - FLEX")
        self.root.geometry("1600x850")
        self.root.configure(bg="#2b2b2b")

        script_dir = os.path.dirname(os.path.abspath(__file__))
        self.lexer_exe = os.path.join(script_dir, "lexer.exe")

        self.descripciones_tokens = {
            "PALABRA_RESERVADA": "Palabra clave del lenguaje",
            "TIPO_DATO": "Tipo de dato primitivo",
            "MODIFICADOR": "Modificador de acceso o almacenamiento",
            "BOOLEANO": "Valor booleano true/false",
            "OPERADOR_ARITMETICO": "Operador aritmético (+, -, *, /, %, ++, --)",
            "OPERADOR_RELACIONAL": "Operador de comparación (==, !=, <, >, <=, >=)",
            "OPERADOR_LOGICO": "Operador lógico (&&, ||, !)",
            "OPERADOR_ASIGNACION": "Operador de asignación (=, +=, -=, *=, /=)",
            "PUNTO_COMA": "Delimitador de fin de instrucción",
            "COMA": "Separador de elementos",
            "PUNTO": "Acceso a miembros",
            "DOS_PUNTOS": "Operador de alcance o etiqueta",
            "PARENTESIS_IZQ": "Paréntesis de apertura",
            "PARENTESIS_DER": "Paréntesis de cierre",
            "LLAVE_IZQ": "Llave de apertura de bloque",
            "LLAVE_DER": "Llave de cierre de bloque",
            "CORCHETE_IZQ": "Corchete de apertura",
            "CORCHETE_DER": "Corchete de cierre",
            "ENTERO": "Literal numérico entero",
            "REAL": "Literal numérico de punto flotante",
            "CADENA": "Literal de cadena de texto",
            "IDENTIFICADOR": "Nombre de variable o función",
            "COMENTARIO": "Comentario de línea",
            "ERROR_LEXICO": "Carácter no reconocido"
        }

        self.crear_interfaz()

    def crear_interfaz(self):
        titulo_frame = tk.Frame(self.root, bg="#1e1e1e", pady=10)
        titulo_frame.pack(fill=tk.X)

        titulo = tk.Label(
            titulo_frame,
            text="🔍 ANALIZADOR LÉXICO CON FLEX",
            font=("Arial", 20, "bold"),
            bg="#1e1e1e",
            fg="#61dafb"
        )
        titulo.pack()

        main_frame = tk.Frame(self.root, bg="#2b2b2b")
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        left_frame = tk.Frame(main_frame, bg="#2b2b2b")
        left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))

        toolbar = tk.Frame(left_frame, bg="#1e1e1e", pady=5)
        toolbar.pack(fill=tk.X)

        btn_style = {
            "bg": "#4CAF50",
            "fg": "white",
            "font": ("Arial", 10, "bold"),
            "relief": tk.FLAT,
            "cursor": "hand2",
            "padx": 15,
            "pady": 5
        }

        tk.Button(
            toolbar,
            text="🔄 Analizar",
            command=self.analizar_codigo,
            bg="#FF9800",
            fg="white",
            font=("Arial", 10, "bold"),
            relief=tk.FLAT,
            cursor="hand2",
            padx=15,
            pady=5
        ).pack(side=tk.LEFT, padx=5)

        tk.Button(
            toolbar,
            text="🗑️ Limpiar",
            command=self.limpiar,
            bg="#f44336",
            fg="white",
            font=("Arial", 10, "bold"),
            relief=tk.FLAT,
            cursor="hand2",
            padx=15,
            pady=5
        ).pack(side=tk.LEFT, padx=5)

      
        tk.Label(
            left_frame,
            text="Código Fuente:",
            font=("Arial", 12, "bold"),
            bg="#2b2b2b",
            fg="#ffffff"
        ).pack(anchor=tk.W, pady=(10, 5))

       
        self.texto_codigo = scrolledtext.ScrolledText(
            left_frame,
            wrap=tk.WORD,
            font=("Consolas", 11),
            bg="#1e1e1e",
            fg="#d4d4d4",
            insertbackground="white",
            selectbackground="#264f78",
            relief=tk.FLAT,
            padx=10,
            pady=10
        )
        self.texto_codigo.pack(fill=tk.BOTH, expand=True)

       
        right_frame = tk.Frame(main_frame, bg="#2b2b2b")
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))

      
        tk.Label(
            right_frame,
            text="Tokens Identificados:",
            font=("Arial", 12, "bold"),
            bg="#2b2b2b",
            fg="#ffffff"
        ).pack(anchor=tk.W, pady=(10, 5))

      
        tabla_frame = tk.Frame(right_frame, bg="#1e1e1e")
        tabla_frame.pack(fill=tk.BOTH, expand=True)

      
        columnas = ("Línea", "Tipo", "Lexema", "Descripción")
        self.tabla_tokens = ttk.Treeview(
            tabla_frame,
            columns=columnas,
            show="tree headings",
            selectmode="browse"
        )

       
        self.tabla_tokens.column("#0", width=50, minwidth=50)
        self.tabla_tokens.column("Línea", width=70, minwidth=70, anchor=tk.CENTER)
        self.tabla_tokens.column("Tipo", width=220, minwidth=200)
        self.tabla_tokens.column("Lexema", width=220, minwidth=200)
        self.tabla_tokens.column("Descripción", width=400, minwidth=350)

        self.tabla_tokens.heading("#0", text="#", anchor=tk.CENTER)
        self.tabla_tokens.heading("Línea", text="Línea", anchor=tk.CENTER)
        self.tabla_tokens.heading("Tipo", text="Tipo de Token", anchor=tk.W)
        self.tabla_tokens.heading("Lexema", text="Lexema", anchor=tk.W)
        self.tabla_tokens.heading("Descripción", text="Descripción", anchor=tk.W)

       
        scrollbar_y = ttk.Scrollbar(tabla_frame, orient=tk.VERTICAL, command=self.tabla_tokens.yview)
        scrollbar_x = ttk.Scrollbar(tabla_frame, orient=tk.HORIZONTAL, command=self.tabla_tokens.xview)
        self.tabla_tokens.configure(yscrollcommand=scrollbar_y.set, xscrollcommand=scrollbar_x.set)

        self.tabla_tokens.grid(row=0, column=0, sticky="nsew")
        scrollbar_y.grid(row=0, column=1, sticky="ns")
        scrollbar_x.grid(row=1, column=0, sticky="ew")

       
        tabla_frame.grid_rowconfigure(0, weight=1)
        tabla_frame.grid_columnconfigure(0, weight=1)

       
        style = ttk.Style()
        style.theme_use("clam")
        style.configure(
            "Treeview",
            background="#1e1e1e",
            foreground="#d4d4d4",
            fieldbackground="#1e1e1e",
            borderwidth=0
        )
        style.configure("Treeview.Heading", background="#2d2d2d", foreground="#ffffff", font=("Arial", 10, "bold"))
        style.map("Treeview", background=[("selected", "#264f78")])

      
        self.stats_frame = tk.Frame(right_frame, bg="#1e1e1e", pady=10)
        self.stats_frame.pack(fill=tk.X, pady=(10, 0))

        self.label_stats = tk.Label(
            self.stats_frame,
            text="Total de tokens: 0",
            font=("Arial", 10),
            bg="#1e1e1e",
            fg="#61dafb"
        )
        self.label_stats.pack()

    def abrir_archivo(self):
        archivo = filedialog.askopenfilename(
            title="Seleccionar archivo",
            filetypes=[
                ("Archivos de texto", "*.txt"),
                ("Archivos C/C++", "*.c *.cpp *.h"),
                ("Todos los archivos", "*.*")
            ]
        )
        if archivo:
            try:
                with open(archivo, 'r', encoding='utf-8') as f:
                    contenido = f.read()
                    self.texto_codigo.delete(1.0, tk.END)
                    self.texto_codigo.insert(1.0, contenido)
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo abrir el archivo:\n{str(e)}")

    def guardar_archivo(self):
        archivo = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[
                ("Archivos de texto", "*.txt"),
                ("Todos los archivos", "*.*")
            ]
        )
        if archivo:
            try:
                with open(archivo, 'w', encoding='utf-8') as f:
                    f.write(self.texto_codigo.get(1.0, tk.END))
                messagebox.showinfo("Éxito", "Archivo guardado correctamente")
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo guardar el archivo:\n{str(e)}")

    def analizar_codigo(self):
      
        if not os.path.exists(self.lexer_exe):
            messagebox.showerror(
                "Error",
                f"No se encontró el ejecutable '{self.lexer_exe}'.\n\n"
                "Por favor, compila el analizador léxico primero usando:\n"
                "compilar.bat"
            )
            return

     
        codigo = self.texto_codigo.get(1.0, tk.END)

        if not codigo.strip():
            messagebox.showwarning("Advertencia", "No hay código para analizar")
            return

        try:
            temp_fd, temp_filename = tempfile.mkstemp(suffix='.txt', text=True)
            with os.fdopen(temp_fd, 'w', encoding='utf-8') as temp_file:
                temp_file.write(codigo)
        except Exception as e:
            messagebox.showerror("Error", f"Error al crear archivo temporal:\n{str(e)}")
            return

        try:
            
            resultado = subprocess.run(
                [self.lexer_exe, temp_filename],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace',
                timeout=10
            )

            
            for item in self.tabla_tokens.get_children():
                self.tabla_tokens.delete(item)

            if resultado.returncode == 0:
             
                try:
                   
                    output = resultado.stdout.strip()

                    if not output:
                        messagebox.showwarning("Advertencia", "El analizador no produjo salida")
                        return

                    tokens = json.loads(output)

                   
                    for idx, token in enumerate(tokens, 1):
                        tipo = token.get("tipo", "?")
                        lexema = token.get("lexema", "?")
                        descripcion = self.descripciones_tokens.get(tipo, "Token desconocido")

                        self.tabla_tokens.insert(
                            "",
                            tk.END,
                            text=str(idx),
                            values=(
                                token.get("linea", "?"),
                                tipo,
                                lexema,
                                descripcion
                            )
                        )

                    
                    self.label_stats.config(text=f"Total de tokens: {len(tokens)}")

                 
                    tipos = {}
                    errores = 0
                    for token in tokens:
                        tipo = token.get("tipo", "DESCONOCIDO")
                        tipos[tipo] = tipos.get(tipo, 0) + 1
                        if tipo == "ERROR_LEXICO":
                            errores += 1

                    stats_text = f"Total de tokens: {len(tokens)}"
                    if errores > 0:
                        stats_text += f" | Errores léxicos: {errores}"
                    self.label_stats.config(text=stats_text)

                except json.JSONDecodeError as e:
                    messagebox.showerror(
                        "Error",
                        f"Error al parsear la salida del analizador:\n\n"
                        f"Error JSON: {str(e)}\n\n"
                        f"Salida recibida:\n{resultado.stdout[:500]}"
                    )
            else:
                error_msg = resultado.stderr if resultado.stderr else "Error desconocido"
                messagebox.showerror(
                    "Error",
                    f"Error al ejecutar el analizador (código {resultado.returncode}):\n\n{error_msg}"
                )

        except subprocess.TimeoutExpired:
            messagebox.showerror("Error", "El análisis excedió el tiempo límite")
        except Exception as e:
            messagebox.showerror("Error", f"Error inesperado:\n{str(e)}")
        finally:
           
            try:
                os.unlink(temp_filename)
            except:
                pass

    def limpiar(self):
        self.texto_codigo.delete(1.0, tk.END)
        for item in self.tabla_tokens.get_children():
            self.tabla_tokens.delete(item)
        self.label_stats.config(text="Total de tokens: 0")

def main():
    root = tk.Tk()
    app = AnalizadorLexicoGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
