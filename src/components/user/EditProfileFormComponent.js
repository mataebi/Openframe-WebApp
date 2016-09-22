'use strict';

import React from 'react';
import { connect } from 'react-redux';
import { reduxForm, Field } from 'redux-form';

import CustomInputComponent from '../form/CustomInputComponent';

import { getCurrentUser } from '../../reducers/user/index';

require('styles/user/EditProfileForm.scss');

class EditProfileFormComponent extends React.Component {
  componentDidMount() {
    setTimeout(function() {
      this.refs.fullName.getRenderedComponent().focus();
    }.bind(this), 0);
  }

  doCloseActions() {
    if (this.props.closeActions && this.props.closeActions.length) {
      this.props.closeActions.each(action => {
        action();
      });
    }
  }

  onSubmit(fields) {
    if (fields.password !== fields.confirmPassword) {
      return false;
    }
    delete fields.confirmPassword;
    this.handleSubmit(fields);
  }

  _handleChangePassword(e) {
    e.preventDefault();
    this.props.updateVisibleModal('reset-password');
  }

  render() {
    const { handleSubmit, submitText, currentUser } = this.props;

    let _submitText = submitText || 'Submit';

    return (
      <form onSubmit={handleSubmit}>
          <Field withRef ref="fullName" name="full_name" component={CustomInputComponent} type="text" placeholder="First Last" label="Full name" />

          <Field name="username" component={CustomInputComponent} type="text" placeholder="username" label="Username" />

          <Field name="email" component={CustomInputComponent} type="text" placeholder="email" label="Email" />

          { !currentUser
            ? <div>
                <Field name="password" component={CustomInputComponent} type="password" placeholder="password" label="Password" />
                <Field name="passwordConfirm" component={CustomInputComponent} type="password" placeholder="confirm password" label="Confirm password" />
              </div>
            :null
          }

          <Field name="website" component={CustomInputComponent} type="text" placeholder="http://..." label="Website" />
          <Field name="twitter" component={CustomInputComponent} type="text" placeholder="handle" label="Twitter" />

          { currentUser
            ? <div className="form-group">
                  <a href="#" onClick={::this._handleChangePassword}>Change password</a>
              </div>
            : null
          }
          <div className="form-group">
              <button href="#" className="btn btn-default btn-fw">{ _submitText }</button>
          </div>
      </form>
    );
  }
}

EditProfileFormComponent = reduxForm({
  form: 'profile'
})(EditProfileFormComponent);

EditProfileFormComponent = connect(
  state => ({ // mapStateToProps
    initialValues: {
      ...getCurrentUser(state.user),
      passwordConfirm: ''
    },
    currentUser: getCurrentUser(state.user)
  })
)(EditProfileFormComponent);

EditProfileFormComponent.displayName = 'EditProfileFormComponent';

// Uncomment properties you need
// EditProfileFormComponent.propTypes = {};
// EditProfileFormComponent.defaultProps = {};

export default EditProfileFormComponent;
