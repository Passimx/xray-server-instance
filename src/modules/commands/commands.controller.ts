import { Body, Controller, Post } from '@nestjs/common';
import { CommandsService } from './commands.service';
import { CommandsDto } from './dto/commands.dto';

@Controller('commands')
export class CommandsController {
  constructor(private readonly commandsService: CommandsService) {}

  @Post()
  runCommands(@Body() body: CommandsDto) {
    return this.commandsService.runCommands(body.commands);
  }
}
