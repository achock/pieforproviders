import React, { useEffect, useState } from 'react'
import './Dashboard.css'

export function Dashboard() {
  const [users, setUsers] = useState([])

  useEffect(() => {
    fetch('/api/v1/users', {
      headers: { Accept: 'application/vnd.pieforproviders.v1+json' }
    })
      .then(response => response.json())
      .then(json => setUsers(json))
      .catch(error => console.log(error))
  }, [])
  return (
    <div className='Dashboard'>
      <p>I'm the dashboard</p>
      {users.map(user => (
        <p key={user.email}>
          {user.full_name}: {user.email}
        </p>
      ))}
    </div>
  )
}
