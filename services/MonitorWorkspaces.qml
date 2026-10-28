pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var blocks: ({})

    function readBlocks(text) {
        const next = {};
        for (const line of String(text || "").split("\n")) {
            const fields = line.split("\t");
            const block = Number(fields[0]);
            if (fields.length >= 3 && fields[1] && Number.isInteger(block) && block >= 0)
                next[fields[1]] = block;
        }
        blocks = next;
    }

    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.readBlocks(text())
        onLoadFailed: root.readBlocks("")
    }

    function offsetFor(monitor) {
        const block = blocks[monitor?.name];
        if (block !== undefined) return block * 10;
        const active = monitor?.activeWorkspace?.id ?? 1;
        return Math.floor((Math.max(1, active) - 1) / 10) * 10;
    }

    function idsFor(monitor, offset, workspaces) {
        const own = Array.from({length: 10}, (_, i) => offset + i + 1);
        const guests = workspaces.filter(ws => ws.id > 0 && ws.monitor === monitor?.name && !own.includes(ws.id)).map(ws => ws.id);
        guests.sort((a, b) => a - b);
        return own.concat(guests);
    }
}
