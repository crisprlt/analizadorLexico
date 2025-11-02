import tkinter as tk
from tkinter import ttk, scrolledtext, filedialog, messagebox
import subprocess
import json
import os
import tempfile

class AnalizadorCompletoGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Analizador Léxico, Sintáctico y Semántico")
        self.root.geometry("1800x900")
        self.root.configure(bg="#2b2b2b")

        script_dir = os.path.dirname(os.path.abspath(__file__))
        self.parser_exe = os.path.join(script_dir, "parser.exe")

        self.crear_interfaz()

    def crear_interfaz(self):
        # Título
        titulo_frame = tk.Frame(self.root, bg="#1e1e1e", pady=10)
        titulo_frame.pack(fill=tk.X)

        titulo = tk.Label(
            titulo_frame,
            text="🔬 ANALIZADOR COMPLETO - Léxico + Sintáctico + Semántico",
            font=("Arial", 20, "bold"),
            bg="#1e1e1e",
            fg="#61dafb"
        )
        titulo.pack()

        # Frame principal
        main_frame = tk.Frame(self.root, bg="#2b2b2b")
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Panel izquierdo (código fuente)
        left_frame = tk.Frame(main_frame, bg="#2b2b2b")
        left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))

        # Barra de herramientas
        toolbar = tk.Frame(left_frame, bg="#1e1e1e", pady=5)
        toolbar.pack(fill=tk.X)

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

        # Editor de código con numeración de líneas
        editor_frame = tk.Frame(left_frame, bg="#1e1e1e")
        editor_frame.pack(fill=tk.BOTH, expand=True)

        self.texto_codigo = scrolledtext.ScrolledText(
            editor_frame,
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

        # Código de ejemplo
        codigo_ejemplo = """int x = 10;
float y = 3.14;
int resultado;

if (x > 5) {
    resultado = x + 2;
}

for (int i = 0; i < 10; i++) {
    x = x + 1;
}
"""
        self.texto_codigo.insert(1.0, codigo_ejemplo)

        # Panel derecho (resultados)
        right_frame = tk.Frame(main_frame, bg="#2b2b2b")
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))

        # Notebook para pestañas
        self.notebook = ttk.Notebook(right_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)

        # Pestaña: Tabla de Símbolos
        simbolos_frame = tk.Frame(self.notebook, bg="#1e1e1e")
        self.notebook.add(simbolos_frame, text="📋 Tabla de Símbolos")

        columnas_simbolos = ("Nombre", "Tipo", "Línea", "Usado")
        self.tabla_simbolos = ttk.Treeview(
            simbolos_frame,
            columns=columnas_simbolos,
            show="headings",
            selectmode="browse"
        )

        self.tabla_simbolos.column("Nombre", width=200, minwidth=150)
        self.tabla_simbolos.column("Tipo", width=150, minwidth=100)
        self.tabla_simbolos.column("Línea", width=100, minwidth=80, anchor=tk.CENTER)
        self.tabla_simbolos.column("Usado", width=100, minwidth=80, anchor=tk.CENTER)

        self.tabla_simbolos.heading("Nombre", text="Nombre Variable")
        self.tabla_simbolos.heading("Tipo", text="Tipo de Dato")
        self.tabla_simbolos.heading("Línea", text="Línea")
        self.tabla_simbolos.heading("Usado", text="Usado")

        scrollbar_simbolos = ttk.Scrollbar(simbolos_frame, orient=tk.VERTICAL, command=self.tabla_simbolos.yview)
        self.tabla_simbolos.configure(yscrollcommand=scrollbar_simbolos.set)

        self.tabla_simbolos.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar_simbolos.pack(side=tk.RIGHT, fill=tk.Y)

        # Pestaña: Errores
        errores_frame = tk.Frame(self.notebook, bg="#1e1e1e")
        self.notebook.add(errores_frame, text="❌ Errores")

        columnas_errores = ("Tipo", "Línea", "Mensaje")
        self.tabla_errores = ttk.Treeview(
            errores_frame,
            columns=columnas_errores,
            show="headings",
            selectmode="browse"
        )

        self.tabla_errores.column("Tipo", width=150, minwidth=100)
        self.tabla_errores.column("Línea", width=100, minwidth=80, anchor=tk.CENTER)
        self.tabla_errores.column("Mensaje", width=500, minwidth=300)

        self.tabla_errores.heading("Tipo", text="Tipo de Error")
        self.tabla_errores.heading("Línea", text="Línea")
        self.tabla_errores.heading("Mensaje", text="Descripción del Error")

        scrollbar_errores = ttk.Scrollbar(errores_frame, orient=tk.VERTICAL, command=self.tabla_errores.yview)
        self.tabla_errores.configure(yscrollcommand=scrollbar_errores.set)

        self.tabla_errores.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar_errores.pack(side=tk.RIGHT, fill=tk.Y)

        # Estilo para Treeview
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

        # Panel de estadísticas
        self.stats_frame = tk.Frame(right_frame, bg="#1e1e1e", pady=10)
        self.stats_frame.pack(fill=tk.X, pady=(10, 0))

        self.label_resultado = tk.Label(
            self.stats_frame,
            text="✅ Estado: Listo para analizar",
            font=("Arial", 12, "bold"),
            bg="#1e1e1e",
            fg="#4CAF50"
        )
        self.label_resultado.pack(pady=5)

        self.label_stats = tk.Label(
            self.stats_frame,
            text="Variables: 0 | Errores: 0",
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
        # Verificar ejecutable
        if not os.path.exists(self.parser_exe):
            messagebox.showerror(
                "Error",
                f"No se encontró el ejecutable '{self.parser_exe}'.\n\n"
                "Por favor, compila el analizador primero usando:\n"
                "compilar_completo.bat"
            )
            return

        # Obtener código
        codigo = self.texto_codigo.get(1.0, tk.END)

        if not codigo.strip():
            messagebox.showwarning("Advertencia", "No hay código para analizar")
            return

        # Crear archivo temporal
        try:
            temp_fd, temp_filename = tempfile.mkstemp(suffix='.txt', text=True)
            with os.fdopen(temp_fd, 'w', encoding='utf-8') as temp_file:
                temp_file.write(codigo)
        except Exception as e:
            messagebox.showerror("Error", f"Error al crear archivo temporal:\n{str(e)}")
            return

        try:
            # Ejecutar analizador
            resultado = subprocess.run(
                [self.parser_exe, temp_filename],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace',
                timeout=10
            )

            # Limpiar tablas
            for item in self.tabla_simbolos.get_children():
                self.tabla_simbolos.delete(item)
            for item in self.tabla_errores.get_children():
                self.tabla_errores.delete(item)

            # Procesar salida
            try:
                output = resultado.stdout.strip()

                if not output:
                    messagebox.showwarning("Advertencia", "El analizador no produjo salida")
                    return

                datos = json.loads(output)

                # Tabla de símbolos
                tabla_simbolos = datos.get("tabla_simbolos", [])
                for simbolo in tabla_simbolos:
                    self.tabla_simbolos.insert(
                        "",
                        tk.END,
                        values=(
                            simbolo.get("nombre", "?"),
                            simbolo.get("tipo", "?"),
                            simbolo.get("linea", "?"),
                            "✓" if simbolo.get("usado", False) else "✗"
                        )
                    )

                # Errores
                errores = datos.get("errores", [])
                for error in errores:
                    tipo_error = error.get("tipo", "desconocido").upper()
                    self.tabla_errores.insert(
                        "",
                        tk.END,
                        values=(
                            tipo_error,
                            error.get("linea", "?"),
                            error.get("mensaje", "?")
                        )
                    )

                # Estadísticas
                exito = datos.get("exito", False)
                num_variables = len(tabla_simbolos)
                num_errores = len(errores)

                if exito:
                    self.label_resultado.config(
                        text="✅ Análisis exitoso - Sin errores",
                        fg="#4CAF50"
                    )
                else:
                    self.label_resultado.config(
                        text="❌ Análisis con errores",
                        fg="#f44336"
                    )

                self.label_stats.config(
                    text=f"Variables declaradas: {num_variables} | Errores: {num_errores}"
                )

                # Cambiar a pestaña de errores si hay errores
                if num_errores > 0:
                    self.notebook.select(1)  # Pestaña de errores

            except json.JSONDecodeError as e:
                messagebox.showerror(
                    "Error",
                    f"Error al parsear la salida del analizador:\n\n"
                    f"Error JSON: {str(e)}\n\n"
                    f"Salida recibida:\n{resultado.stdout[:500]}"
                )

        except subprocess.TimeoutExpired:
            messagebox.showerror("Error", "El análisis excedió el tiempo límite")
        except Exception as e:
            messagebox.showerror("Error", f"Error inesperado:\n{str(e)}")
        finally:
            # Eliminar archivo temporal
            try:
                os.unlink(temp_filename)
            except:
                pass

    def limpiar(self):
        self.texto_codigo.delete(1.0, tk.END)
        for item in self.tabla_simbolos.get_children():
            self.tabla_simbolos.delete(item)
        for item in self.tabla_errores.get_children():
            self.tabla_errores.delete(item)
        self.label_resultado.config(
            text="✅ Estado: Listo para analizar",
            fg="#4CAF50"
        )
        self.label_stats.config(text="Variables: 0 | Errores: 0")

def main():
    root = tk.Tk()
    app = AnalizadorCompletoGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
