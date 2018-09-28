import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import NavBar from './react_components/NavBar'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
      <NavBar/>,
      document.getElementById("root")
      // document.body.appendChild(document.createElement('div'))
  )
})
