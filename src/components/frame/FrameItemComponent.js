'use strict';

import React from 'react';

require('styles/frame/FrameItem.scss');

let checkmarkIcon = require('../../images/frame-checkmark.svg');
let settingsIcon = require('../../images/settings.svg');

class FrameItemComponent extends React.Component {

  handleClick() {
    let {selectFrame, frame} = this.props;
    selectFrame(frame.id);
  }

  render() {
  	let {isCurrent, isOwner, frame} = this.props;

  	let isConnected = frame.connected;
    let current_artwork_ref = frame.current_artwork_ref;

    let className = 'sidebar__row sidebar__row--frame';
    className += isCurrent ? ' sidebar_row--frame-active' : '';

    let isConnectedClass = 'selected-frame-indicator';
    isConnectedClass += isConnected ? ' selected-frame-indicator--connected' : '';

    return (
      <li className={className} onClick={this.handleClick.bind(this)}>
        { isCurrent
        	? <img className="mark-frame-active" src={checkmarkIcon} />
        	: ''
        }

        <span className={isConnectedClass}>&bull;</span>

        <div className="frame-name">{ frame.name }</div>

        { isOwner
        	? <a className="btn-frame-settings" href="#" data-toggle="modal" data-target="#FrameSettingsModal" data-frameid="{{- id }}">
	            <img className="icon-settings" src={settingsIcon} />
	        </a>
	        : ''
        }

        <div className="frame-status displaying">
        	{ current_artwork_ref ? current_artwork_ref.author_name + ' - ' + current_artwork_ref.title : 'No Artwork Displayed'}
        </div>
    </li>
    );
  }
}

FrameItemComponent.displayName = 'FrameFrameItemComponent';

// Uncomment properties you need
FrameItemComponent.propTypes = {};
FrameItemComponent.defaultProps = {};

export default FrameItemComponent;
