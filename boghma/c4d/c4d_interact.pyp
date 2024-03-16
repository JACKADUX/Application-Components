# -*- coding: utf-8 -*-  

__author__ = "JACKADUX"
import os
import c4d
import sys
import json
import socket
from importlib import reload
from pathlib import Path
from ctypes import pythonapi, c_int, py_object
from c4d.threading import C4DThread

# 查找导入共用库
PLUGINPATH, f = os.path.split(__file__)
LIBS_PATH = os.path.join(PLUGINPATH, "lib")
TEMP_QUEUE_PATH = os.path.join(PLUGINPATH, "res", "_temp.json")
CONFIGS_PATH = os.path.join(PLUGINPATH, "res", "configs.json")


PLUGINID: int = 10000000
PLUGINNAME: str = "Helper"
PLUGINVERSION: str = "0.1.0"
PLUGINHELP: str = ""


_sh_thread = None
ID_SP_EVENT = 1

sys.path.insert(0, LIBS_PATH)
try:
    pass
finally:
    sys.path.pop(0)


def read_json(source_path):
    with open(source_path, 'r', encoding='UTF-8') as file:
        strings = file.read()
    file.close()
    return json.loads(strings)

def write_json(source_path, data):
    with open(source_path, 'w', encoding='UTF-8') as file:
        file.write(json.dumps(data, sort_keys=True, indent=4,separators=(', ', ':'), ensure_ascii=0))
    file.close()

class Listener(C4DThread):
    _stopThread = False
    _conn = None
    _addr = None
    _socket = None

    def __init__(self, host, port) -> None:
        super().__init__()
        self.host = host
        self.port = port

    def OpenSocket(self):
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._socket.bind((self.host, self.port))
        self._socket.listen(5)
        self._socket.settimeout(1)
        return (self._socket is not None)

    def CloseSocket(self):
        # close connection
        if self._conn is not None:
            self._conn.close()
        # close socket
        if self._socket is not None:
            self._socket.close()
        # signal the thread
        self._stopThread = True


    def TestDBreak(self):
        return self._stopThread

    def Main(self):
        # check for connections
        while not self.TestBreak():
            try:
                self._conn, self._addr = self._socket.accept()
            except Exception as err:
                continue
            while not self.TestBreak():
                #check for data
                data = self._conn.recv(4096)
                if not data: 
                    break
                write_json(TEMP_QUEUE_PATH, json.loads(data.decode('utf-8')))
                c4d.SpecialEventAdd(PLUGINID, ID_SP_EVENT, 0)
                            
            self._conn.close()

class MyMessageData(c4d.plugins.MessageData):


    def CoreMessage(self, id, bc):

        if id == PLUGINID:
            pythonapi.PyCapsule_GetPointer.restype = c_int
            pythonapi.PyCapsule_GetPointer.argtypes = [py_object]
            P1MSG_UN1 = bc.GetVoid(c4d.BFM_CORE_PAR1)
            P1MSG_EN1 = pythonapi.PyCapsule_GetPointer(P1MSG_UN1, None)
            if P1MSG_EN1 == ID_SP_EVENT:
                data = read_json(TEMP_QUEUE_PATH)

        c4d.EventAdd()
        return True


class Main_CMD(c4d.plugins.CommandData):

    def Execute(self, doc):        
        return True

    def RestoreLayout(self, sec_ref):
        return self.GetDialog().Restore(pluginid=PLUGINID, secret=sec_ref)



def PluginMessage(id, data):
    global _sh_thread

    if id == c4d.C4DPL_PROGRAM_STARTED:
        config = read_json(CONFIGS_PATH)
        _sh_thread = Listener(config["host"], config["port"])
        if _sh_thread.OpenSocket():
            _sh_thread.Start(c4d.THREADMODE_ASYNC, c4d.THREADPRIORITY_LOWEST)
        return True

    if id == c4d.C4DPL_ENDPROGRAM: 
        if (_sh_thread):
            _sh_thread.End()
            _sh_thread.CloseSocket()
        return True


if __name__ == '__main__':
    icon_path = os.path.join(PLUGINPATH, "icon.png")
    icon = c4d.bitmaps.BaseBitmap()
    icon.InitWith(icon_path)
    c4d.plugins.RegisterCommandPlugin(id = PLUGINID,
                                      str = PLUGINNAME,
                                      info = 0,
                                      icon = icon,
                                      help = PLUGINHELP,
                                      dat = Main_CMD())
    c4d.plugins.RegisterMessagePlugin(id=PLUGINID+1, str="", info=0, dat=MyMessageData())