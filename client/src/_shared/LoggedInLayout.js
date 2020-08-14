import React from 'react'
import PropTypes from 'prop-types'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import { Breadcrumb } from 'antd'
import '_assets/styles/layouts.css'

export function LoggedInLayout({ children, title }) {
  return (
    <>
      <div className="w-full shadow p-4 flex items-center">
        <img
          alt="Pie for Providers logo"
          src={pieSliceLogo}
          className="w-8 mr-2"
        />{' '}
        <div className="text-2xl font-semibold flex-grow">
          Pie for Providers
        </div>
        <div>Logout</div>
      </div>
      <div className="w-full medium:h-full bg-mediumGray p-4">
        {title && (
          <Breadcrumb className="mb-4">
            <Breadcrumb.Item>{title}</Breadcrumb.Item>
          </Breadcrumb>
        )}
        <div className="bg-white px-4 pb-6 pt-8 shadow rounded-sm">
          {children}
        </div>
      </div>
    </>
  )
}

LoggedInLayout.propTypes = {
  children: PropTypes.element,
  title: PropTypes.string
}
