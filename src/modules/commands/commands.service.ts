import { BadRequestException, Injectable } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';
import { logger } from '../../common/logger/logger';

@Injectable()
export class CommandsService {
  public async runCommands(commands: string[]): Promise<string[]> {
    const result: string[] = [];
    const execPromise = promisify(exec);

    for (const command of commands) {
      const { stdout, stderr } = await execPromise(command);
      if (stderr) {
        logger.error(stderr);
        throw new BadRequestException(stderr);
      }

      result.push(stdout);
    }
    return result;
  }
}
