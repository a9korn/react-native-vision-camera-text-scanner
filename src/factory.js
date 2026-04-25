import { NitroModules } from 'react-native-nitro-modules';
let _factory;
function getFactory() {
    if (_factory == null) {
        _factory = NitroModules.createHybridObject('TextRecognizerFactory');
    }
    return _factory;
}
export function createTextRecognizer(options) {
    return getFactory().createTextRecognizer(options);
}
export function createTextRecognizerOutput(options) {
    return getFactory().createTextRecognizerOutput(options);
}
