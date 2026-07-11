-- Función para cargar charts de eventos externos
function loadExternalEvents(chartName)
    runHaxeCode([[
        import backend.Song;
        var extraChart = Song.getChart(']]..chartName..[[', game.songName);
        if(extraChart != null) {
            for (event in extraChart.events) {
                for (i in 0...event[1].length) {
                    game.makeEvent(event, i);
                }
            }
        }
    ]])
end

function onCreate()
    -- Ejecutamos la carga para ambos archivos
    loadExternalEvents('saws-events')
    loadExternalEvents('cam-events')
end
