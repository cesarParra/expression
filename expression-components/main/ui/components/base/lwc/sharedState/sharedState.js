let _data;
let _listeners = [];

const SharedState = {
    registerListener: (listener) => {
        _listeners.push(listener);
    },
    setData: (newVal) => {
        _data = newVal;
        _listeners.forEach((listener) => {
            listener(_data);
        });
    },
    getData: () => {
        return _data;
    },
};

Object.freeze(SharedState);

export {SharedState};
