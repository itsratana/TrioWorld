let tg = null;

class Tg {

    data = null;
    user = null;

    static tgReady() {
        window.Telegram.WebApp.ready();
        tg = window.Telegram.WebApp;
        this.data = tg.initDataUnsafe;
        this.user = this.data.user;
    }

    static getRawUser() {
        return this.user;
    }

    static getUser() {
        console.log(this.user);
        return JSON.stringify(this.user);
    }
    
    static getInitData() {
        return JSON.stringify(this.data);
    }
}

window.onload = function () {
    Tg.tgReady();
}