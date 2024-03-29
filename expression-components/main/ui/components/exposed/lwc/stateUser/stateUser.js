/**
 * Created by cesarparra on 29/3/24.
 */

import {LightningElement} from 'lwc';
import {SharedState} from "c/sharedState";

export default class StateUser extends LightningElement {
    stateData;

    connectedCallback() {
        SharedState.registerListener(this.refreshStateData.bind(this));
    }

    refreshStateData() {
        return (this.stateData = SharedState.getData());
    }

    updateState(newValue) {
        SharedState.setData(newValue);
    }

    updateStateToBlue() {
        this.updateState('blue');
    }

    updateStateToRed() {
        this.updateState('red');
    }
}
