const storedState = localStorage.getItem('sources');
const startingState = storedState ? JSON.parse(storedState) : null;
const app = Elm.Main.init({
    flags: {
        windowWidth: window.innerWidth,
        windowHeight: window.innerHeight,
        startingSources: startingState,
        version: version
    },
    node: document.getElementById('multitube')
});

var youtubeApiIsReady = false;
function onYouTubeIframeAPIReady() {
    youtubeApiIsReady = true;
    console.log("youtube api is ready");
}

function createOrGetPlayer(token) {
    return new Promise((resolve, reject) => {
        const existing = YT.get(token);
        if(existing) {
            resolve(existing);
        } else {
            new YT.Player(token, {
                events: {
                    'onReady': (event) => {
                        resolve(event.target)
                    }
                }
            });
        }
    });
}

// ports
 app.ports.setSources.subscribe(function(state) {
    localStorage.setItem('sources', state);
 });

 app.ports.runSynchronizedAction.subscribe(function(actionJsonString) {
    const action = JSON.parse(actionJsonString);
    
    const playersPromises = action.streams
        .filter(s => s.platform === 'Youtube')
        .map(s => createOrGetPlayer(s.source));

    Promise.all(playersPromises)
        .then(players => {
            players.map(player => {
                if(action.action === 'Play' && player.playVideo) {
                    player.playVideo();
                }
                if(action.action === 'Pause' && player.pauseVideo) {
                    player.pauseVideo();
                }
            });
        })
        .catch(err => {
            console.error(`error while evaluating players: ${err}`);
        });
 });