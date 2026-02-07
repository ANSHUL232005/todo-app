import { contextBridge, ipcRenderer } from 'electron'

contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: {
    send: (channel: string, ...args: any[]) => ipcRenderer.send(channel, ...args),
    on: (channel: string, func: Function) => {
      ipcRenderer.on(channel, (event: any, ...args: any[]) => func(...args))
    },
    once: (channel: string, func: Function) => {
      ipcRenderer.once(channel, (event: any, ...args: any[]) => func(...args))
    }
  }
})
