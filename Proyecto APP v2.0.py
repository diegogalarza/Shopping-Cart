##############################################
##      BASES DE DATOS 1 - PROYECTO 1       ##
##  BRAYAN VERA, DIEGO GALARZA, JUAN OTOYA  ##
##                  2018-1                  ##
##############################################

#--------REFERENCIAS---------##
#https://www.youtube.com/watch?v=60vqM47PP5M
#https://gist.github.com/marians/8e41fc817f04de7c4a70
#https://www.youtube.com/watch?v=R6LUMXrAoCE
#https://github.com/WoobyDoo/PINBALL-TronEdition/blob/master/TEST%20DEF.py

from tkinter import *
import math, random, sys, json, couchdb
def show(window): window.deiconify()
def hide(window):window.withdraw()
def execute(f): auth_window.after(200, f)
def exit(ventana):
    ventana.destroy()
## User Authentication Window
auth_window = Tk()
auth_window.geometry("300x300")
auth_window.title("COUCH DB MANAGER")
auth_window.config(bg="white")
auth_window.resizable(0, 0)

wall = PhotoImage(file="wallp.png")

canvas_main = Canvas(auth_window, width=500, height=500)
canvas_main.pack(fill='none')
canvas_main.create_image(150, 125, image=wall, anchor='center')

#b1_auth = Button(auth_window, text = " LOGIN ", command=lambda: show(cart_window))
b1_auth = Button(auth_window, text = " LOGIN ", command=lambda: verify(cart_window))
b1_auth.place(x=120, y=270)

user=Label(text="Name").place(x=10,y=220)
uswid=Entry(auth_window)
uswid.place(x=10,y=240)

password=Label(text="Password").place(x=160,y=220)
passw=Entry(auth_window)
passw.place(x=160,y=240)

## Add-To-Cart Window
cart_window = Toplevel(auth_window)
cart_window.geometry("500x500")
cart_window.title("CART")
cart_window.config(bg="white")
cart_window.resizable(0, 0)


#b1_add = Button(cart_window, text = " ADD TO CART ", command=lambda: execute(AddToCart()))
b1_add = Button(cart_window, text = " ADD TO CART ", command=lambda: AddToCart())
b1_add.place(x=120, y=420)
objLabel = Label(cart_window, text="Objet to add:").place(x=100,y=370)
objectCart=Entry(cart_window)
objectCart.place(x=100,y=390)
b2_add = Button(cart_window, text = " REMOVE FROM CART ", command=lambda: execute(RemoveFCart()))
b2_add.place(x=260, y=420)
numLabel = Label(cart_window, text="Quantity of objects:").place(x=280,y=370)
numCart=Entry(cart_window)
numCart.place(x=280,y=390)
b3_add = Button(cart_window, text = " VIEW RECIPT ", command=lambda: show(Process_window))
b3_add.place(x=400, y=470)
widget = Label(cart_window, text= "LISTADO DE PRODUCTOS DISPONIBLES:\n")
widget.pack()
widgetProd = Text(cart_window, width = 20, height = 20)
widgetProd.place(x=50, y=45)
widgetProd.config(state=DISABLED)
widgetQuant = Text(cart_window, width = 20, height = 20)
widgetQuant.place(x=250, y=45)
widgetQuant.config(state=DISABLED)

def showProducts():
    global widgetProd, data
    widgetProd.config(state = NORMAL)
    widgetQuant.config(state=NORMAL)
    with open("producto.json") as json_data:
        data= json.load(json_data)
        for j in data:
            #print (j['nombre'])
            widgetProd.insert(END, j['nombre']+"\n")
            widgetQuant.insert(END, j['cantidadDisp']+"\n")
        widgetProd.config(state = DISABLED)
        widgetQuant.config(state=DISABLED)

def verify(window):
    global data2, us, passw, cart_window
    userData = uswid.get()
    passwData = passw.get()
    usrBOOL = False
    pswrBOOL = False
    with open("cliente.json") as json_data2:
        data2= json.load(json_data2)
        for m in data2:
            verus = m['nombreDeUsuario'] 
        for n in data2:
            #print(n['contrasena'])
            verpas = n['contrasena']
            if(userData == verus and passwData == verpas):
                print("HOLAA")
            show(window)

## Process Window
Process_window = Toplevel(auth_window)
Process_window.geometry("500x500")
Process_window.title("CART2")
Process_window.config(bg="white")
Process_window.resizable(0, 0)

b1_proc = Button(Process_window, text = " CANCEL ORDER ", command=lambda: clear())
b1_proc.place(x=200, y=420)
b2_proc = Button(Process_window, text = "    EXIT    ", command=lambda: exit(auth_window))
b2_proc.place(x=440, y=470)
widget2 = Label(Process_window, text= "LISTADO DE PRODUCTOS EN PROCESO:\n")
widget2.pack()
widgetProc = Text(Process_window, width = 30, height = 12)
widgetProc.place(x=50 , y=50)
widgetProc.config(state=DISABLED)
widgetPrice = Text(Process_window, width = 15, height = 12)
widgetPrice.place(x=300 , y=50)
widgetPrice.config(state=DISABLED)
widget3 = Label(Process_window, text= "LISTADO DE PRODUCTOS COMPRADOS EN 2017:\n")
widget3.place(x=120,y=250)

def clear():
    global widgetProc
    widgetProc.config(state = NORMAL)
    widgetProc.delete(1.0, END)
    widgetPrice.config(state = NORMAL)
    widgetPrice.delete(1.0, END)

def AddToCart():
    global data, widgetProc
    element = objectCart.get()
    for a in data:
        if(element == a['nombre']):
            widgetProc.config(state = NORMAL)
            widgetProc.insert(END, objectCart.get()+"\t\t"+numCart.get()+" Unit(s)\n")
        widgetPrice.config(state = NORMAL)
        #objPrice = a['precio']
        #print(int(a['precio'])*int(numCart.get()))
    widgetPrice.insert(END, "$\t"+" COP")
    widgetPrice.config(state=DISABLED)
    widgetProc.config(state=DISABLED)
def RemoveFCart():
    global numCart, data
    print("Elimina el elem seleccionado")
    
showProducts()

cart_window.withdraw()
Process_window.withdraw()

auth_window.mainloop()


