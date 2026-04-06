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
      try {
        const { stdout, stderr } = await execPromise(command);

        if (stderr) {
          logger.error(stderr);
          throw new BadRequestException(stderr);
        }

        result.push(stdout);
      } catch (stderr) {
        logger.error(stderr);
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
        throw new BadRequestException(stderr?.stderr || stderr?.message);
      }
    }

    return result;
  }
}
