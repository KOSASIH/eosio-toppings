import { combineReducers } from 'redux';
import { combineEpics } from 'redux-observable';

import { counterReducer } from './counter';

import { combinedEpic as infoPageEpic, combinedReducer as infoPageReducer } from '../pages/InfoPage/InfoPageReducer';
import { combinedEpic as blocklistPageEpic, combinedReducer as blocklistPageReducer } from '../pages/BlocklistPage/BlocklistPageReducer';


export const rootEpic = combineEpics(
  infoPageEpic,
  blocklistPageEpic,
);

export const rootReducer = combineReducers({
  counter: counterReducer,
  infoPage: infoPageReducer,
  blocklistPage: blocklistPageReducer,
})
