import { promisify } from 'util';
import { exec } from 'child_process';

export const usersInit = async () => {
  const execPromise = promisify(exec);
  await execPromise('ls');
};
