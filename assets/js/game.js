export function createSecretCode() {
    var arr = [];
    while (arr.length < 4) {
        var r = Math.floor(Math.random() * 10);
        if (arr.indexOf(r) === -1) arr.push(r);
    }

    return arr;
}

export function checkIfUnique(num) {
    var s = Array.from(new Set(num));
    return s.length === num.length;
}
