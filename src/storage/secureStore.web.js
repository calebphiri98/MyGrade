function storage(key) {
  if (typeof window === 'undefined') {
    throw new Error('Browser storage unavailable');
  }
  return key === 'teacherId'
    ? window.sessionStorage
    : window.localStorage;
}

export async function getItemAsync(key) {
  if (typeof window === 'undefined') return null;
  return storage(key).getItem('mygrade_' + key);
}

export async function setItemAsync(key, value) {
  storage(key).setItem('mygrade_' + key, value);
}

export async function deleteItemAsync(key) {
  storage(key).removeItem('mygrade_' + key);
}
