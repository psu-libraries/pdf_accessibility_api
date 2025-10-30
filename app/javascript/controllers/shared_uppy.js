export function checkForForbiddenCharacters(files) {
    let forbidden_chars = /[^A-Za-z0-9\.\-_ ]/
    if (files[0].name.match(forbidden_chars) != null) {
      let message = 'File names can only contain letters, numbers, spaces, periods, underscores, and hyphens.'
      alert(message)
      throw Error(message)
    }
  }